
public class AlurePlay {
	private static bool quit = false;
	private static AL.Source src;
	private static AL.Buffer buf;

	static void eos_callback(void* unused, AL.ALuint unused2) {
		quit = true;
		print("Bye-bye!\n");
	}

	private static void free_resources() {
		if (AL.is_source(src)) {
			AL.delete_source(1, out src);
		}
		
		if (AL.is_buffer(buf)) {
			AL.delete_buffer(1, out buf);
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

		buf = Alure.create_buffer_from_file(args[1]);
		if (!AL.is_buffer(buf)) {
			stderr.printf("Could not load %s: %s\n", args[1], Alure.get_error_string());
			free_resources();
			return 1;
		}

		src.set_parami(AL.BUFFER, (AL.ALint)buf);
		if (!Alure.play_source(src, eos_callback)) {
			stderr.printf("Failed to start source!\n");
			free_resources();
			return 1;
		}

		while (!quit) {
			Alure.sleep(0.125f);
			Alure.update();
		}

		free_resources();
		return 0;
	}
}
