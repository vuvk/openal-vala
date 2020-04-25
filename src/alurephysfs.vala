
public class AlurePhysfs {
    private static bool quit = false;
    private static Alure.Stream stream;
    private static AL.Source src;

    private const int CHUNK_LENGTH = 128000;
    private const int NUM_BUFS = 3;
    private const string ARCHIVE_NAME = "../samples/assets.7z";
    private const string FILE_NAME = "example.wav";

    static void eos_callback(void* unused, AL.ALuint unused2) {
        quit = true;
        print("Bye-bye!\n");
    }

    private static string get_physfs_error() {
        return PHYSFS.get_error_by_code(PHYSFS.get_last_error_code());
    }

    private static void free_resources() {
        if (AL.is_source(src)) {
            Alure.stop_source(src, false);

            if (stream != null) {
                stream.destroy();
                stream = null;
            }

            AL.delete_source(1, out src);
        }

        Alure.shutdown_device();

        if (PHYSFS.is_init()) {
            PHYSFS.deinit();
        }
    }

    public static int main(string[] args) {
        if (!Alure.init_device()) {
            stderr.printf("Failed to open OpenAL device: %s\n", Alure.get_error_string());
            return 1;
        }

        AL.gen_source(1, out src);
        if (AL.get_error() != AL.Error.NO_ERROR) {
            stderr.printf("Failed to create OpenAL source!\n");
            free_resources();
            return 1;
        }

        if (!PHYSFS.init(args[0])) {
            stderr.printf("Failed to initialize PHYSFS: %s\n", get_physfs_error());
            free_resources();
            return 1;
        }

        if (!PHYSFS.mount(ARCHIVE_NAME, "", true)) {
            stderr.printf("Failed to mount archive \"%s\": %s\n", ARCHIVE_NAME, get_physfs_error());
            free_resources();
            return 1;
        }

        // read wav file fron archive to memory
        var wav = new PHYSFS.File.open_read(FILE_NAME);
        if (wav == null) {
            stderr.printf("Failed to read file: %s\n", get_physfs_error());
            free_resources();
            return 1;
        }
        int64 len = wav.length();
        uint8[] buffer = new uint8[len];
        if (wav.read_bytes(buffer, len) != len) {
            stderr.printf("Error when read file: %s\n", get_physfs_error());
            free_resources();
            return 1;
        }
        wav = null;

        Alure.stream_size_is_microsec(true);

        stream = new Alure.Stream.from_static_memory(buffer, CHUNK_LENGTH);
        if (stream == null) {
            stderr.printf("Could not load stream: %s\n", Alure.get_error_string());
            free_resources();
            return 1;
        }

        if (!Alure.play_source_stream(src, stream, NUM_BUFS, 0, eos_callback)) {
            stderr.printf("Failed to play stream: %s\n", Alure.get_error_string());
            quit = true;
        }

        while (!quit) {
            Alure.sleep(0.125f);
            Alure.update();
        }

        free_resources();
        return 0;
    }
}
