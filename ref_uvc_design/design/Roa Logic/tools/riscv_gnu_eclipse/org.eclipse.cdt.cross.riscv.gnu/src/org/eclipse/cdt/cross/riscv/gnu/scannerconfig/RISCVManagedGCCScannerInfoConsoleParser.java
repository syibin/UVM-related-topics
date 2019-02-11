/*******************************************************************************
* This program and the accompanying materials 
* are made available under the terms of the Common Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/cpl-v10.html
* 
* Contributors:
*   RoaLogic BV - RISC-V Gnu Toolchain port
*******************************************************************************/

package org.eclipse.cdt.cross.riscv.gnu.scannerconfig;

import org.eclipse.cdt.build.core.scannerconfig.CfgInfoContext;
import org.eclipse.cdt.core.model.CoreModel;
import org.eclipse.cdt.core.settings.model.ICProjectDescription;
import org.eclipse.cdt.make.core.scannerconfig.IScannerInfoCollector;
import org.eclipse.cdt.make.core.scannerconfig.InfoContext;
import org.eclipse.cdt.make.internal.core.scannerconfig.gnu.GCCScannerInfoConsoleParser;
import org.eclipse.cdt.make.internal.core.scannerconfig2.PerProjectSICollector;
import org.eclipse.cdt.managedbuilder.core.IConfiguration;
import org.eclipse.core.resources.IProject;

 public class RISCVManagedGCCScannerInfoConsoleParser extends GCCScannerInfoConsoleParser
 {
   Boolean m_bManagedBuildOnState;
 
   public boolean processLine(String sLine)
   {
     if (isManagedBuildOn())
       return false;
     return super.processLine(sLine);
   }
 
   public void shutdown() {
     if (!isManagedBuildOn()) {
       super.shutdown();
     }
     this.m_bManagedBuildOnState = null;
   }
 
   public void startup(IProject oProject, IScannerInfoCollector oCollector) {
     if (isManagedBuildOn())
       return;
     super.startup(oProject, oCollector);
   }
 
   protected boolean isManagedBuildOn() {
     if (this.m_bManagedBuildOnState == null)
       this.m_bManagedBuildOnState = 
         Boolean.valueOf(doCalcManagedBuildOnState());
     return this.m_bManagedBuildOnState.booleanValue();
   }
 
   protected boolean doCalcManagedBuildOnState() {
     IScannerInfoCollector oCr = getCollector();
     InfoContext oC;
     if ((oCr instanceof PerProjectSICollector))
       oC = ((PerProjectSICollector)oCr).getContext();
     else
       return false;
     // yunlu comment InfoContext oC;
     IProject oProject = oC.getProject();
     ICProjectDescription oDes = CoreModel.getDefault()
       .getProjectDescription(oProject, false);
     CfgInfoContext oCc = CfgInfoContext.fromInfoContext(oDes, oC);
     if (oCc != null) {
       IConfiguration cfg = oCc.getConfiguration();
       return cfg.isManagedBuildOn();
     }
     return false;
   }
 }
