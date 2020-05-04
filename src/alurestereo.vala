
public class AlureStereo {
    private static bool quit = false;
    private static Alure.Stream stream;
    private static AL.Source src;

    private const int CHUNK_LENGTH = 128000;
    private const int NUM_BUFS = 3;
    private const int64 DELAY = 20; // in sec
    private const string FILE_NAME = "../samples/vase3.wav";

    private const float DEG_TO_RAD_COEFF = (float)(Math.PI / 180.0);
    private const float RADIUS = 1.5f;

    private static float deg_to_rad(float deg) {
        return deg * DEG_TO_RAD_COEFF;
    }

    // callback for repeat sound
    static void eos_callback(void* userdata, AL.ALuint source) {
        Alure.stop_source(source, false);

        unowned Alure.Stream stream = (Alure.Stream)userdata;
        stream.rewind();
        if (!Alure.play_source_stream(src, stream, NUM_BUFS, 0, eos_callback, userdata)) {
            stderr.printf(@"Failed to play stream: $(Alure.get_error_string())\n");
            quit = true;
        }
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
    }

    public static int main(string[] args) {
        if (!Alure.init_device()) {
            stderr.printf(@"Failed to open OpenAL device: $(Alure.get_error_string())\n");
            return 1;
        }

        AL.ALfloat[] position = { 0, 0, -1 };
        AL.ALfloat angle = 0.0f;

        AL.gen_source(1, out src);
        if (AL.get_error() != AL.Error.NO_ERROR) {
            stderr.printf("Failed to create OpenAL source!\n");
            Alure.shutdown_device();
            return 1;
        }

        src.set_paramfv(AL.POSITION, position);
        src.set_parami(AL.SOURCE_RELATIVE, AL.TRUE);

        Alure.stream_size_is_microsec(true);

        stream = new Alure.Stream.from_file(FILE_NAME, CHUNK_LENGTH);
        if (stream == null) {
            stderr.printf(@"Could not load $FILE_NAME: $(Alure.get_error_string())\n");
            free_resources();
            return 1;
        }

        if (!Alure.play_source_stream(src, stream, NUM_BUFS, 0, eos_callback, stream)) {
            stderr.printf(@"Failed to play stream: $(Alure.get_error_string())\n");
            quit = true;
        }

        var start_dt = new DateTime.now_local();


        while (!quit) {
            Alure.sleep(0.125f);
            Alure.update();

            // update source position
            angle += 5;
            if (angle > 360.0f) {
                angle -= 360.0f;
            }
            position[0] =  RADIUS * Math.cosf(deg_to_rad(angle));
            position[2] = -RADIUS * Math.sinf(deg_to_rad(angle));
            src.set_paramfv(AL.POSITION, position);

            var cur_dt = new DateTime.now_local();
            int64 diff = (int64)cur_dt.difference(start_dt);
            diff /= 1000000; // to sec
            if (diff >= DELAY) {
                quit = true;
                print("Bye-bye!\n");
            }
        }

        free_resources();
        return 0;
    }
}
