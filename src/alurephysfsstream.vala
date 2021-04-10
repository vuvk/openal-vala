
public class AlurePhysfsStream {
    private static bool quit = false;
    private static Alure.Stream stream;
    private static AL.Source src;

    private const int CHUNK_LENGTH = 128000;
    private const int NUM_BUFS = 3;
    private const string ARCHIVE_NAME = "../samples/assets.7z";
    private const string FILE_NAME = "example.wav";

    static void* open_callback(string filename, AL.Uint mode = 0) {
        if (!PHYSFS.exists(filename))
            return null;

        return (void*) new PHYSFS.File.open_read(filename);
    }

    static void close_callback(void* handle) {
        if (handle != null) {
            ((PHYSFS.File)handle).close();
        }
    }

    static AL.Sizei read_callback(void* handle, [CCode (array_length = false)] AL.Ubyte[] buffer, AL.Uint bytes) {
        if (handle == null) {
            return -1;
        }

        return (AL.Sizei) ((PHYSFS.File)handle).read(buffer, 1, bytes);
    }

    static AL.Sizei write_callback(void* handle, [CCode (array_length = false)] AL.Ubyte[] buffer, AL.Uint bytes) {
        if (handle == null) {
            return -1;
        }

        return (AL.Sizei) ((PHYSFS.File)handle).write(buffer, 1, bytes);
    }

    static int64 seek_callback(void* handle, int64 offset, Alure.Seek whence) {
        if (handle == null) {
            return -1;
        }

        unowned PHYSFS.File file = (PHYSFS.File)handle;

        switch (whence) {
            case Alure.Seek.SET:
                break;

            case Alure.Seek.END:
                offset = file.length() - offset;
                break;

            case Alure.Seek.CUR:
                offset = file.tell() + offset;
                break;
        }

        /* return -1 if error */
        if (file.seek(offset) == 0) {
            return -1;
        }

        /* return new pos */
        return offset;
    }

    static void eos_callback(void* unused, AL.Uint unused2) {
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

            AL.delete_source(1, ref src);
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

        if (!Alure.set_io_callbacks(open_callback,
                                    close_callback,
                                    read_callback,
                                    write_callback,
                                    seek_callback)) {
            stderr.printf("Failed to set IO callbacks: %s\n", Alure.get_error_string());
            return 1;
        }

        AL.gen_source(1, out src);
        if (AL.get_error() != AL.Error.NO_ERROR) {
            stderr.printf("Failed to create OpenAL source!\n");
            free_resources();
            return 1;
        }

        if (!PHYSFS.init(null/*args[0]*/)) {
            stderr.printf("Failed to initialize PHYSFS: %s\n", get_physfs_error());
            free_resources();
            return 1;
        }

        if (!PHYSFS.mount(ARCHIVE_NAME, "", true)) {
            stderr.printf("Failed to mount archive \"%s\": %s\n", ARCHIVE_NAME, get_physfs_error());
            free_resources();
            return 1;
        }

        Alure.stream_size_is_microsec(true);

        stream = new Alure.Stream.from_file("example.wav", CHUNK_LENGTH);
        if (stream == null) {
            stderr.printf("Could not load %s: %s\n", FILE_NAME, Alure.get_error_string());
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
