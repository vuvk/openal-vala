/*
 * OpenAL Source Play Example
 */

/* This file contains an example for playing a sound buffer. */

using AL;
using ALC;

ALC.Device device;
ALC.Context ctx;


/* LoadBuffer loads the named audio file into an OpenAL buffer object, and
 * returns the new buffer ID.
 */
AL.Uint load_sound(string filename) {
    AL.Error err;
    AL.BufferFormat format;
    AL.Buffer buffer;
    Sndfile.File sndfile;
    Sndfile.Info sfinfo = {};
    short[] membuf;
    int num_frames;
    AL.Sizei num_bytes;

    /* Open the audio file and check that it's usable. */
    sndfile = new Sndfile.File(filename, Sndfile.Mode.READ, ref sfinfo);
    if (sndfile == null) {
        stderr.printf(@"Could not open audio in $filename: $(Sndfile.File.strerror(sndfile))\n");
        return 0;
    }

    if (sfinfo.frames < 1 || sfinfo.frames > (int)(int.MAX/sizeof(short))/sfinfo.channels) {
        stderr.printf(@"Bad sample count in $filename ($(sfinfo.frames))\n");
        return 0;
    }

    /* Get the sound format, and figure out the OpenAL format */
    switch (sfinfo.channels) {
        case 1 : format = AL.BufferFormat.MONO16; break;
        case 2 : format = AL.BufferFormat.STEREO16; break;
        default :
            stderr.printf("Unsupported channel count: %d\n", sfinfo.channels);
            return 0;
    }

    /* Decode the whole audio file to a buffer. */
    membuf = new short[sfinfo.frames * sfinfo.channels];

    num_frames = sndfile.readf_short(membuf, sfinfo.frames);
    if (num_frames < 1) {
        stderr.printf("Failed to read samples in $filename: ($num_frames)\n");
        return 0;
    }
    num_bytes = (AL.Sizei)(num_frames * sfinfo.channels) * (AL.Sizei)sizeof(short);

    /* Buffer the audio data into a new buffer object, then free the data and
     * close the file.
     */
    AL.gen_buffer(1, out buffer);
    buffer.set_data(format, (uint8[])membuf, num_bytes, sfinfo.samplerate);

    membuf = null;
    sndfile = null;

    /* Check if an error occured, and clean up if so. */
    err = AL.get_error();
    if (err != AL.Error.NO_ERROR) {
        stderr.printf("OpenAL Error: %s\n", AL.get_string(err));
        if (buffer != 0 && AL.is_buffer(buffer)) {
            AL.delete_buffer(1, ref buffer);
        }
        return 0;
    }

    return buffer;
}


/* InitAL opens a device and sets up a context using default attributes, making
 * the program ready to call OpenAL functions. */
bool init_openal() {
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
void close_openal() {
    if (ctx == null) {
        return;
    }

    ctx = null;
    device = null;
}


int main(string[] args) {
    AL.Source source;
    AL.Buffer buffer;
    AL.Float offset;
    AL.SourceState state = AL.SourceState.STOPPED;

    /* Print out usage if no arguments were specified */
    if (args.length < 2) {
        stderr.printf(@"Usage: $(args[0]) [-device <name>] <filename>\n");
        return 1;
    }

    /* Initialize OpenAL. */
    if (!init_openal()) {
        return 1;
    }

    /* Load the sound into a buffer. */
    buffer = load_sound(args[1]);
    if (!AL.is_buffer(buffer)) {
        close_openal();
        return 1;
    }

    /* Create the source to play the sound with. */
    AL.gen_source(1, out source);
    source.set_parami(AL.BUFFER, (AL.Int)buffer);
    if (AL.get_error() != AL.Error.NO_ERROR) {
        print("Failed to setup sound source\n");
        return 1;
    }

    /* Play the sound until it finishes. */
    source.play();
    do {
        Thread.usleep(10000);
        AL.Int param;
        source.get_parami(AL.SOURCE_STATE, out param);
        state = (AL.SourceState)param;

        /* Get the source offset. */
        source.get_paramf(AL.SourceBufferPosition.SEC_OFFSET, out offset);
        stdout.printf("\rOffset: %f  ", offset);
        stdout.flush();
    } while (AL.get_error() == AL.Error.NO_ERROR && state == AL.SourceState.PLAYING);
    print("\nBye-bye!\n");

    /* All done. Delete resources, and close down OpenAL. */
    AL.delete_source(1, ref source);
    AL.delete_buffer(1, ref buffer);

    close_openal();

    return 0;
}
