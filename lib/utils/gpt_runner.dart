import 'dart:convert';
import 'dart:io';

Future<String> runExecutable(String prompt) async {
  try {
    ProcessResult result;

    if (Platform.isWindows) {
      // On Windows
      result = await Process.run('wingpt.exe', [prompt]);
    } else if (Platform.isLinux) {
      // On Linux
      result = await Process.run('./linuxgpt', [prompt]);
    } else {
      throw UnsupportedError('Unsupported platform');
    }

    // Output the results
    print('stdout: ${result.stdout}');
    print('stderr: ${result.stderr}');
    print('exit code: ${result.exitCode}');
    return result.stdout;
  } catch (e) {
    print('Error running executable: $e');
    return "ERROR";
  }
}
