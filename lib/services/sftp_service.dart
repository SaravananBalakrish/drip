import 'dart:convert';
import 'dart:io';
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../utils/environment.dart';

enum SftpFlag{
  fileDownloadSuccessFully,
  fileDownloadFailed,
  fileUploadSuccessFully,
  fileUploadFailed
}

class SftpService {
  SSHClient? _sshClient;
  SftpClient? _sftpClient;

  Future<void> connect() async {
    try {
      final pem = await rootBundle.loadString(Environment.privateKeyPath);
      final privateKey = SSHKeyPair.fromPem(pem);

      final socket = await SSHSocket.connect(
        Environment.sftpIpAddress,
        Environment.sftpPort,
      );

      _sshClient = SSHClient(
        socket,
        username: 'ubuntu',
        identities: [...privateKey],
      );

      _sftpClient = await _sshClient!.sftp();
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('SFTP connect() error: $e');
        print('StackTrace: $stackTrace');
      }
      rethrow;
    }
  }

  Future<List<SftpName>> listFilesInPath(String path) async {
    if (_sftpClient == null) {
      await connect();
    }

    try {
      final items = await _sftpClient!.listdir(path);
      if (kDebugMode) {
        for (final item in items) {
          print(item.longname);
        }
      }
      return items;
    } catch (e) {
      if (kDebugMode) {
        print('listFilesInDirectory error: $e');
      }
      rethrow;
    } finally {
      disconnect();
    }
  }

  Future<SftpFlag> uploadFile({
    required String localFilePath,
    required String remoteFileName,
  }) async {
    try {
      if (_sftpClient == null) {
        await connect();
      }

      final remoteFile = await _sftpClient!.open(
        remoteFileName,
        mode: SftpFileOpenMode.truncate | SftpFileOpenMode.write,
      );
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;
      String filePath = '$appDocPath/$localFilePath.txt';
      final localFile = File(filePath);

      if (!await localFile.exists()) {
        throw Exception('Local file does not exist: $localFilePath');
      }

      await remoteFile.write(localFile.openRead().cast()).done;

      if (kDebugMode) {
        print('File uploaded successfully.');
      }
      return SftpFlag.fileUploadSuccessFully;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('uploadFile() error: $e');
        print('StackTrace: $stackTrace');
      }
      return SftpFlag.fileUploadFailed;
    } finally {
      disconnect();
    }
  }

  Future<SftpFlag> downloadFile({
    required String remoteFilePath,
    String localFileName = 'bootFile.txt',
  }) async {
    try {
      if (_sftpClient == null) {
        await connect();
      }

      // Read remote file content
      final remoteFile = await _sftpClient!.open(remoteFilePath);
      final content = await remoteFile.readBytes();

      // Get local file path
      final appDocDir = await getApplicationDocumentsDirectory();
      final localPath = '${appDocDir.path}/$localFileName';
      final localFile = File(localPath);

      // Write content to local file
      await localFile.writeAsBytes(content);

      if (kDebugMode) {
        print('File downloaded successfully to $localPath');
        print('File content: ${latin1.decode(content)}');
      }

      return SftpFlag.fileDownloadSuccessFully;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('downloadFile() error: $e');
        print('StackTrace: $stackTrace');
      }
      return SftpFlag.fileDownloadFailed;
    } finally {
      disconnect();
    }
  }


  Future<void> disconnect() async {
    try {
      _sshClient?.close();
      await _sshClient?.done;
    } catch (e) {
      if (kDebugMode) {
        print('disconnect() error: $e');
      }
    } finally {
      _sshClient = null;
      _sftpClient = null;
    }
  }
}
