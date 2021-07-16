/*
 * Copyright 2020 ZUP IT SERVICOS EM TECNOLOGIA E INOVACAO SA
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package br.com.zup.yoga;

import java.io.*;
import java.net.URL;

public class SoLibraryLoader {
  public static String getExt() {
    String operatingSystem = System.getProperty("os.name");
    if (operatingSystem.equals("Linux"))
      return "so";
    else if (operatingSystem.equals("Mac OS X"))
      return "dylib";
    else
      return "dll";
  }

  public static void loadLib(String name) {
    String path = "/lib" + name + "." + getExt();
    URL url = SoLibraryLoader.class.getResource(path);

    try {
      final File file = File.createTempFile(name, ".lib");
      file.deleteOnExit();

      final InputStream in = url.openStream();
      final OutputStream out = new BufferedOutputStream(new FileOutputStream(file));

      int len = 0;
      byte[] buffer = new byte[8192];
      while ((len = in.read(buffer)) > -1)
        out.write(buffer, 0, len);
      out.close();
      in.close();

      System.load(file.getAbsolutePath());
    } catch (IOException e) {
      e.printStackTrace();
    }
  }
}
