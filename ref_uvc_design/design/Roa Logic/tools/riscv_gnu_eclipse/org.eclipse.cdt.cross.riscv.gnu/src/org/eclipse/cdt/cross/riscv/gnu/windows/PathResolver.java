/*******************************************************************************
* This program and the accompanying materials 
* are made available under the terms of the Common Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/cpl-v10.html
* 
* Contributors:
*   RoaLogic BV - RISC-V Gnu Toolchain port
*******************************************************************************/

package org.eclipse.cdt.cross.riscv.gnu.windows;

import java.io.File;

import org.eclipse.cdt.cross.riscv.gnu.Tools;
import org.eclipse.cdt.managedbuilder.core.IBuildPathResolver;
import org.eclipse.cdt.managedbuilder.core.IConfiguration;

 public class PathResolver
   implements IBuildPathResolver
 {
   private static boolean ms_bChecked = false;
   private static String ms_sBinGNUARC = null;
   private static final String REGISTRY_KEY = "SOFTWARE\\GNURISCV\\4.8.1";
   private static final String PATH_NAME = "InstallPath";
   private static final String DELIMITER_WIN = ";";
 
   public String[] resolveBuildPaths(int pathType, String variableName, String variableValue, IConfiguration configuration)
   {
     System.out.println(PathResolver.class.getName() + 
       " resolveBuildPaths()");
     return variableValue.split(";");
   }
 
   public static String getBinPath() {
     if (!ms_bChecked)
       checkRegistry();
     return ms_sBinGNUARC;
   }
 
   private static synchronized void checkRegistry()
   {
     if (ms_bChecked) {
       return;
     }
     ms_sBinGNUARC = null;
     if (!Tools.isWindows()) {
       return;
     }
 
     String sInstallDir = Tools.getLocalMachineValue("SOFTWARE\\GNURISCV\\4.1.1", "InstallPath");
     if (sInstallDir != null)
     {
       String sToolPath = sInstallDir + "\\bin";
       File oDir = new File(sToolPath);
       if ((oDir.exists()) && (oDir.isDirectory()))
       {
         ms_sBinGNUARC = sToolPath;
       }
     }
     ms_bChecked = true;
   }
 }

