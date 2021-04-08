
using AL;
using ALC;

ALC.Device device;
ALC.Context ctx;

/* Define the number of buffers and buffer size (in milliseconds) to use. 4
 * buffers with 8192 samples each gives a nice per-chunk size, and lets the
 * queue last for almost one second at 44.1khz. */
const int NUM_BUFFERS = 4;
const int BUFFER_SAMPLES = 8192;

public class StreamPlayer {
    /* These are the buffers and source to play out through OpenAL with */
    private AL.Buffer[] buffers = new AL.Buffer[NUM_BUFFERS];
    private AL.Source source;

    /* Handle for the audio file */
    private Sndfile.File sndfile;
    private Sndfile.Info sfinfo;
    private short[] membuf;

    /* The format of the output stream (sample rate is in sfinfo) */
    private AL.BufferFormat format;

    /* Creates a new player object, and allocates the needed OpenAL source and
     * buffer objects. Error checking is simplified for the purposes of this
     * example, and will cause an abort if needed. */
    public StreamPlayer() {
        /* Generate the buffers and source */
        AL.gen_buffers(buffers.length, buffers);
        if (AL.get_error() != AL.Error.NO_ERROR) {
            stderr.printf("Could not create buffers\n");
            return;
        }

        AL.gen_source(1, out source);
        if (AL.get_error() != AL.Error.NO_ERROR) {
            stderr.printf("Could not create source\n");
            return;
        }

        /* Set parameters so mono sources play out the front-center speaker and
         * won't distance attenuate. */
        source.set_param3i(AL.POSITION, 0, 0, -1);
        source.set_parami(AL.SOURCE_RELATIVE, AL.TRUE);
        source.set_parami(AL.ROLLOFF_FACTOR, 0);
        if (AL.get_error() != AL.Error.NO_ERROR) {
            stderr.printf("Could not set source parameters");
            return;
        }
    }

    /* Destroys a player object, deleting the source and buffers. No error handling
     * since these calls shouldn't fail with a properly-made player object. */
    ~StreamPlayer() {
        close_file();

        AL.delete_source(1, ref source);
        AL.delete_buffers(NUM_BUFFERS, buffers);
        if (AL.get_error() != AL.Error.NO_ERROR) {
            stderr.printf("Failed to delete object IDs\n");
        }
    }

    /* Opens the first audio stream of the named file. If a file is already open,
     * it will be closed first. */
    public bool open_file(string filename) {
        close_file();

        /* Open the audio file and check that it's usable. */
        sndfile = new Sndfile.File(filename, Sndfile.Mode.READ, ref sfinfo);
        if (sndfile == null) {
            stderr.printf("Could not open audio in %s: %s\n", filename, sndfile.strerror(null));
            return false;
        }

        /* Get the sound format, and figure out the OpenAL format */
        switch (sfinfo.channels) {
            case 1 : format = AL.BufferFormat.MONO16;   break;
            case 2 : format = AL.BufferFormat.STEREO16; break;
            default:
                stderr.printf("Unsupported channel count: %d\n", sfinfo.channels);
                sndfile = null;
                return false;
        }

        membuf = new short[BUFFER_SAMPLES * sfinfo.channels];

        return true;
    }

    /* Closes the audio file stream */
    public void close_file() {
        sndfile = null;
        membuf = null;
    }

    /* Prebuffers some audio from the file, and starts playing the source */
    public bool start() {
        /* Rewind the source position and clear the buffer queue */
        source.rewind();
        source.set_parami(AL.BUFFER, 0);

        /* Fill the buffer queue */
        for (int i = 0; i < NUM_BUFFERS; ++i) {
            /* Get some data to give it to the buffer */
            int slen = sndfile.readf_short(membuf, BUFFER_SAMPLES);
            if (slen < 1) {
                break;
            }

            slen *= (int) (sfinfo.channels * sizeof(short));
            buffers[i].set_data(format, (uint8[])membuf, (AL.Sizei)slen, sfinfo.samplerate);
        }

        if (AL.get_error() != AL.Error.NO_ERROR) {
            stderr.printf("Error buffering for playback\n");
            return false;
        }

        /* Now queue and start playback! */
        source.queue_buffers(NUM_BUFFERS, buffers);
        source.play();
        if (AL.get_error() != AL.Error.NO_ERROR) {
            stderr.printf("Error starting playback\n");
            return false;
        }

        return true;
    }

    public bool update() {
        AL.SourceState state;
        AL.Int processed;

        /* Get relevant source info */
        AL.Int param;
        source.get_parami(AL.SOURCE_STATE, out param);
        state = (AL.SourceState)param;
        source.get_parami(AL.BUFFERS_PROCESSED, out processed);
        if (AL.get_error() != AL.Error.NO_ERROR) {
            stderr.printf("Error checking source state\n");
            return false;
        }

        /* Unqueue and handle each processed buffer */
        while (processed > 0) {
            AL.Buffer bufid = 0;
            int slen;

            if (AL.is_buffer(bufid)) {
                source.unqueue_buffer(1, ref bufid);
                processed--;
            }

            /* Read the next chunk of data, refill the buffer, and queue it
             * back on the source */
            slen = sndfile.readf_short(membuf, BUFFER_SAMPLES);
            if (slen > 0) {
                slen *= (int) (sfinfo.channels * sizeof(short));
                bufid.set_data(format, (uint8[])membuf, (AL.Sizei)slen, sfinfo.samplerate);
                source.queue_buffer(1, ref bufid);
            }

            AL.Error error = AL.get_error();
            if (error != AL.Error.NO_ERROR) {
                stderr.printf("Error buffering data: %s\n", AL.get_string(error));
                return false;
            }
        }

        /* Make sure the source hasn't underrun */
        if (state != AL.SourceState.PLAYING && state != AL.SourceState.PAUSED) {
            AL.Int queued;

            /* If no buffers are queued, playback is finished */
            source.get_parami(AL.BUFFERS_QUEUED, out queued);
            if (queued == 0) {
                return false;
            }

            source.play();
            if (AL.get_error() != AL.Error.NO_ERROR) {
                stderr.printf("Error restarting playback\n");
                return false;
            }
        }

        return true;
    }


    /* InitAL opens a device and sets up a context using default attributes, making
     * the program ready to call OpenAL functions. */
    static bool init_openal() {
        /* Open and initialize a device */
        device = new ALC.Device(null);
        if (device == null) {
            stderr.printf("Could not open a device!\n");
            return false;
        }

        ctx = new ALC.Context(device, null);
        if (ctx == null || !ctx.make_current()) {
            stderr.printf("Could not set a context!\n");
            return false;
        }

        string? name = null;
        if (device.is_extension_present("ALC_ENUMERATE_ALL_EXT")) {
            name = device.get_string(ALC.ALL_DEVICES_SPECIFIER);
        }

        if (name == null || device.get_error() != ALC.Error.NO_ERROR) {
            name = device.get_string(ALC.DEVICE_SPECIFIER);
        }

        print(@"Opened \"$name\"\n");

        return true;
    }

    /* CloseAL closes the device belonging to the current context, and destroys the
     * context. */
    static void close_openal() {
        if (ctx == null) {
            return;
        }

        ctx = null;
        device = null;
    }

    public static int main(string[] args) {
        /* Print out usage if no arguments were specified */
        if (args.length < 2) {
            stderr.printf("Usage: %s [-device <name>] <filenames...>\n", args[0]);
            return 1;
        }

        /* Initialize OpenAL. */
        if (!init_openal()) {
            return 1;
        }

        StreamPlayer player = new StreamPlayer();

        /* Play each file listed on the command line */
        for (int i = 1; i < args.length; ++i) {
            if (!player.open_file(args[i])) {
                continue;
            }

            stdout.printf("Playing: %s (%dhz)\n", args[i], player.sfinfo.samplerate);

            if (!player.start()) {
                player.close_file();
                continue;
            }

            while (player.update()) {
                Thread.usleep(10000);
            }

            /* All done with this file. Close it and go to the next */
            player.close_file();
        }
        print("Done.\n");

        /* All files done. Delete the player, and close down OpenAL */
        player = null;

        close_openal();

        return 0;
    }

}
