/*******************************************************************************
* This program and the accompanying materials 
* are made available under the terms of the Common Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/cpl-v10.html
* 
* Contributors:
*     RoaLogic BV - RISC-V Gnu Toolchain port
*******************************************************************************/

package org.eclipse.cdt.cross.riscv.gnu.windows;

import org.eclipse.cdt.cross.riscv.gnu.Tools;
import org.eclipse.cdt.managedbuilder.core.IConfiguration;
import org.eclipse.cdt.managedbuilder.envvar.IBuildEnvironmentVariable;
import org.eclipse.cdt.managedbuilder.envvar.IConfigurationEnvironmentVariableSupplier;
import org.eclipse.cdt.managedbuilder.envvar.IEnvironmentVariableProvider;
import org.eclipse.cdt.managedbuilder.internal.envvar.BuildEnvVar;

 public class ConfigurationEnvironmentSupplier
   implements IConfigurationEnvironmentVariableSupplier
 {
   static final String VARNAME_PATH = "PATH";
   static final String DELIMITER_UNIX = ":";
   static final String PROPERTY_DELIMITER = "path.separator";
 
   public IBuildEnvironmentVariable getVariable(String variableName, IConfiguration configuration, IEnvironmentVariableProvider provider)
   {
     if (!Tools.isWindows()) {
       return null;
     }
     if (variableName == null) {
       return null;
     }
     if (!"PATH".equalsIgnoreCase(variableName)) {
       return null;
     }
     String p = PathResolver.getBinPath();
     if (p != null)
     {
       String sDelimiter = System.getProperty("path.separator", ":");
 
       String sPath = p.replace('/', '\\');
 
       return new BuildEnvVar("PATH", sPath, 
         3, sDelimiter);
     }
     return null;
   }
 
   public IBuildEnvironmentVariable[] getVariables(IConfiguration configuration, IEnvironmentVariableProvider provider)
   {
     IBuildEnvironmentVariable[] tmp = new IBuildEnvironmentVariable[1];
     tmp[0] = getVariable("PATH", configuration, provider);
     if (tmp[0] != null)
       return tmp;
     return null;
   }
 }

