
public class AlureStream {
    private static bool quit = false;
    private static Alure.Stream stream;
    private static AL.Source src;

    private const int CHUNK_LENGTH = 128000;
    private const int NUM_BUFS = 3;

	static void eos_callback(void* unused, AL.ALuint unused2) {
		quit = true;
		print("Bye-bye!\n");
	}

	private static void free_resources() {
		if (AL.is_source(src)) {
			AL.delete_source(1, out src);
		}
        
        if (stream != null) {
            stream.destroy();
            stream = null;
        }

		Alure.shutdown_device();
	}

	public static int main(string[] args) {
		if (args.length < 2) {
			stderr.printf("Usage %s <soundfile>\n", args[0]);
			return 1;
		}

		if (!Alure.init_device()) {
			stderr.printf("Failed to open OpenAL device: %s\n", Alure.get_error_string());
			return 1;
		}
		
		AL.gen_source(1, out src);
		if (AL.get_error() != AL.Error.NO_ERROR) {
			stderr.printf("Failed to create OpenAL source!\n");
			Alure.shutdown_device();
			return 1;
        }
        
        Alure.stream_size_is_microsec(true);

        stream = new Alure.Stream.from_file(args[1], CHUNK_LENGTH);
        if (stream == null) {
            stderr.printf("Could not load %s: %s\n", args[1], Alure.get_error_string());
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
