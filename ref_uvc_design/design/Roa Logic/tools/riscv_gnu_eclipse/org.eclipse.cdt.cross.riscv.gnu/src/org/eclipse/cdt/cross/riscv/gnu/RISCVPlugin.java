/*******************************************************************************
* This program and the accompanying materials 
* are made available under the terms of the Common Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/cpl-v10.html
* 
* Contributors:
*     RoaLogic BV - RISC-V Gnu Toolchain port
*******************************************************************************/

package org.eclipse.cdt.cross.riscv.gnu;

import org.eclipse.core.runtime.ILog;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Plugin;
import org.eclipse.core.runtime.Status;
import org.eclipse.ui.console.ConsolePlugin;
import org.eclipse.ui.console.IConsole;
import org.eclipse.ui.console.IConsoleManager;
import org.eclipse.ui.console.MessageConsole;
import org.osgi.framework.BundleContext;

 public class RISCVPlugin extends Plugin
 {
   public static final String PLUGIN_ID = "org.eclipse.cdt.cross.riscv.gnu";
   public static final String DEFAULT_LOG = "RISC-V Eclipse Plugin Log";
   private static RISCVPlugin m_oPlugin;
 
   public void start(BundleContext oContext)
     throws Exception
   {
     super.start(oContext);
     m_oPlugin = this;
   }
 
   public void stop(BundleContext oContext) throws Exception {
     m_oPlugin = null;
     super.stop(oContext);
   }
 
   public static RISCVPlugin getDefault() {
     return m_oPlugin;
   }
 
   public void log(IStatus oStatus) {
     ILog oLog = getLog();
     if (oStatus.getSeverity() >= 2) {
       oLog.log(oStatus);
     }
     if (isDebugging()) {
       System.err.print("org.eclipse.cdt.cross.riscv.gnu: " + oStatus.getMessage());
       if (oStatus.getCode() != 0) {
         System.err.print("(" + oStatus.getCode() + ")");
       }
       System.out.println("");
       if (oStatus.getException() != null)
         oStatus.getException().printStackTrace();
     }
   }
 
   public static void log(String sMsg, Exception oException)
   {
     getDefault().getLog().log(
       new Status(4, "org.eclipse.cdt.cross.riscv.gnu", sMsg, 
       oException));
   }
 
   public MessageConsole getDefaultConsole() {
     return getConsole("RISC-V Eclipse Plugin Log");
   }
 
   public MessageConsole getConsole(String sName)
   {
     IConsoleManager oConMan = ConsolePlugin.getDefault().getConsoleManager();
     IConsole[] aoConsoles = oConMan.getConsoles();
     for (IConsole oConsole : aoConsoles) {
       if (oConsole.getName().equals(sName)) {
         return (MessageConsole)oConsole;
       }
     }
 
     MessageConsole oNewConsole = new MessageConsole(sName, null);
     oConMan.addConsoles(new IConsole[] { oNewConsole });
     return oNewConsole;
   }
 }
