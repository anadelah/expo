import spawnAsync from '@expo/spawn-async';
import fs from 'fs/promises';
import path from 'path';
import rimraf from 'rimraf';

import {
  createFingerprintAsync,
  createProjectHashAsync,
  diffFingerprintChangesAsync,
} from '../../src/Fingerprint';
import { normalizeOptions } from '../../src/Options';
import { getHashSourcesAsync } from '../../src/sourcer/Sourcer';

describe('managed project test', () => {
  jest.setTimeout(600000);
  const tmpDir = require('temp-dir');
  const projectName = 'fingerprint-e2e-managed';
  const projectRoot = path.join(tmpDir, projectName);

  beforeAll(async () => {
    rimraf.sync(projectRoot);
    await spawnAsync('npx', ['create-expo-app', '-t', 'blank', projectName], {
      stdio: 'inherit',
      cwd: tmpDir,
    });
  });

  afterAll(async () => {
    rimraf.sync(projectRoot);
  });

  it('should have same hash after adding js only library', async () => {
    const hash = await createProjectHashAsync(projectRoot);
    await spawnAsync('npx', ['expo', 'install', '@react-navigation/core'], {
      stdio: 'ignore',
      cwd: projectRoot,
    });
    const hash2 = await createProjectHashAsync(projectRoot);
    expect(hash).toBe(hash2);
  });

  it('should have same hash after updating js code', async () => {
    const hash = await createProjectHashAsync(projectRoot);

    const jsPath = path.join(projectRoot, 'App.js');
    const js = await fs.readFile(jsPath, 'utf8');
    await fs.writeFile(jsPath, `${js}\n// adding comments`);

    const hash2 = await createProjectHashAsync(projectRoot);
    expect(hash).toBe(hash2);
  });

  it('should have different hash after adding native library', async () => {
    const hash = await createProjectHashAsync(projectRoot);
    await spawnAsync('npx', ['expo', 'install', 'expo-updates'], {
      stdio: 'ignore',
      cwd: projectRoot,
    });
    const hash2 = await createProjectHashAsync(projectRoot);
    expect(hash).not.toBe(hash2);
  });

  it('should have different hash after updating `jsEngine`', async () => {
    const hash = await createProjectHashAsync(projectRoot);

    const configPath = path.join(projectRoot, 'app.json');
    const config = JSON.parse(await fs.readFile(configPath, 'utf8'));
    config.jsEngine = 'hermes';
    await fs.writeFile(configPath, JSON.stringify(config, null, 2));

    const hash2 = await createProjectHashAsync(projectRoot);
    expect(hash).not.toBe(hash2);
  });

  it('should have different hash after updating icon file', async () => {
    const hash = await createProjectHashAsync(projectRoot);

    const iconPath = path.join(projectRoot, 'assets', 'icon.png');
    await fs.writeFile(iconPath, '');

    const hash2 = await createProjectHashAsync(projectRoot);
    expect(hash).not.toBe(hash2);
  });

  it('should have different hash after adding js only config-plugin', async () => {
    const hash = await createProjectHashAsync(projectRoot);
    await spawnAsync('npx', ['expo', 'install', 'expo-build-properties'], {
      stdio: 'ignore',
      cwd: projectRoot,
    });
    const hash2 = await createProjectHashAsync(projectRoot);
    expect(hash).not.toBe(hash2);
  });

  it('diffFingerprintChangesAsync - should return diff after adding native library', async () => {
    const fingerprint = await createFingerprintAsync(projectRoot);
    await spawnAsync('npm', ['install', '--save', '@react-native-community/netinfo@9.3.7'], {
      stdio: 'ignore',
      cwd: projectRoot,
    });
    const diff = await diffFingerprintChangesAsync(fingerprint, projectRoot);
    expect(diff).toMatchInlineSnapshot(`
      Array [
        Object {
          "filePath": "node_modules/@react-native-community/netinfo",
          "hash": "9864bf3bf95283fe99774aaeec91965d70f3eab3",
          "reasons": Array [
            "bareRncliAutolinking",
          ],
          "type": "dir",
        },
        Object {
          "contents": "{\\"sourceDir\\":\\"node_modules/@react-native-community/netinfo/android\\",\\"packageImportPath\\":\\"import com.reactnativecommunity.netinfo.NetInfoPackage;\\",\\"packageInstance\\":\\"new NetInfoPackage()\\",\\"buildTypes\\":[],\\"componentDescriptors\\":[],\\"androidMkPath\\":\\"node_modules/@react-native-community/netinfo/android/build/generated/source/codegen/jni/Android.mk\\",\\"cmakeListsPath\\":\\"node_modules/@react-native-community/netinfo/android/build/generated/source/codegen/jni/CMakeLists.txt\\"}",
          "hash": "cb4dfbb38f9151ecd6621bc9e36055540495c463",
          "id": "rncliAutolinkingConfig:@react-native-community/netinfo:android",
          "reasons": Array [
            "bareRncliAutolinking",
          ],
          "type": "contents",
        },
        Object {
          "contents": "{\\"podspecPath\\":\\"node_modules/@react-native-community/netinfo/react-native-netinfo.podspec\\",\\"configurations\\":[],\\"scriptPhases\\":[]}",
          "hash": "40eebce5caf94df11096238a5a2ca648ea9f242e",
          "id": "rncliAutolinkingConfig:@react-native-community/netinfo:ios",
          "reasons": Array [
            "bareRncliAutolinking",
          ],
          "type": "contents",
        },
      ]
    `);
  });
});

describe(`getHashSourcesAsync - managed project`, () => {
  jest.setTimeout(600000);
  const tmpDir = require('temp-dir');
  const projectName = 'fingerprint-e2e-managed';
  const projectRoot = path.join(tmpDir, projectName);

  beforeAll(async () => {
    rimraf.sync(projectRoot);
    await spawnAsync('npx', ['create-expo-app', '-t', 'blank@sdk-47', projectName], {
      stdio: 'inherit',
      cwd: tmpDir,
    });

    // Pin the `expo` package version to prevent the latest version and break snapshot
    await spawnAsync('npm', ['install', '--save', 'expo@47.0.8'], {
      cwd: projectRoot,
    });
  });

  afterAll(async () => {
    rimraf.sync(projectRoot);
  });

  it('should match snapshot', async () => {
    const sources = await getHashSourcesAsync(projectRoot, normalizeOptions());
    expect(sources).toMatchSnapshot();
  });
});
