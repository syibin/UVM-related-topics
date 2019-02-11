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

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Enumeration;
import java.util.Properties;

import org.eclipse.cdt.managedbuilder.core.BuildException;
import org.eclipse.cdt.managedbuilder.core.IManagedCommandLineInfo;
import org.eclipse.cdt.managedbuilder.core.IOption;
import org.eclipse.cdt.managedbuilder.core.ITool;
import org.eclipse.cdt.managedbuilder.core.IToolChain;
import org.eclipse.cdt.managedbuilder.internal.core.ManagedCommandLineGenerator;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;
import org.eclipse.core.variables.VariablesPlugin;
import org.eclipse.ui.statushandlers.StatusManager;

public class RISCVManagedCommandLineGenerator extends ManagedCommandLineGenerator {
	
    public IManagedCommandLineInfo generateCommandLineInfo(ITool oTool, String sCommandName,
            String[] asFlags, String sOutputFlag, String sOutputPrefix, String sOutputName,
            String[] asInputResources, String sCommandLinePattern) {
        return generateCommandLineInfo(oTool, sCommandName, asFlags, sOutputFlag, sOutputPrefix,
                sOutputName, asInputResources, sCommandLinePattern, false);
    }

    
    public IManagedCommandLineInfo generateCommandLineInfo(ITool oTool, String sCommandName, String[] asFlags, String sOutputFlag, String sOutputPrefix, String sOutputName, String[] asInputResources, String sCommandLinePattern, boolean bFlag)
    {
      ArrayList<String> oList = new ArrayList<String>();
      ArrayList<String> oList_compiler_options = new ArrayList<String>();
      ArrayList<String> oList_assembler_options = new ArrayList<String>();
      ArrayList<String> oList_linker_options = new ArrayList<String>();
      
      String sAssemblerWaOptions = "";
      String sLinkerWlOptions = "";
      

      //Which Tool called me?
      boolean bIsCompiler  = false;
      boolean bIsAssembler = false;
      boolean bIsLinker    = false;

      
      {
        ITool oToolSuper = oTool;
        while (oToolSuper.getSuperClass() != null) {
          oToolSuper = oToolSuper.getSuperClass();
        }
        String sID = oToolSuper.getId();
      

        if (sID.indexOf(".compiler") > 0) {
    	    bIsCompiler = true;
        } else if (sID.indexOf(".assembler") > 0) {
    	    bIsAssembler = true;
        } else if (sID.indexOf(".linker") > 0) {
    	    bIsLinker = true;
        }
      }
      
      
      //RISC-V Options
      String  sProcessor = null;
      String  sABI       = null;

      boolean bFDIV      = false;
      String sArch = "";
      
   
      //Get Tool options
      IOption[] oToolOptions = oTool.getOptions();
      for (int i = 0; i < oToolOptions.length; i++) {
          IOption oOption = oToolOptions[i];
          String sID = oOption.getId();
   
          Object oValue = oOption.getValue();
   
          String sCommand = oOption.getCommand();
          if ((oValue instanceof String)) {
             String sVal;
             try {
               sVal = oOption.getStringValue();
             }
             catch (BuildException e) {
               sVal = null;
             }
             
             String sEnumCommand;
             try {
               sEnumCommand = oOption.getEnumCommand(sVal);
             }
             catch (BuildException e1) {
               sEnumCommand = null;
             }
   
             //Insert string analysis here
          }
          else if ((oValue instanceof Boolean)) {
            boolean bVal;
            try {
              bVal = oOption.getBooleanValue();
            }
            catch (BuildException e) {
             bVal = false;
            }

            if (bVal) {
            	//just an example ...
            	if (sID.indexOf(".option.optimization.fdiv") > 0) {
                    bFDIV = true;
                }
            }
          }
      } //next i
    
      
      //Get ToolChain options
      Object oParent = oTool.getParent();
      while ((oParent != null) && (!(oParent instanceof IToolChain))) {
        Object oSuper = oTool.getSuperClass();
        if ((oSuper != null) && ((oSuper instanceof ITool)))
          oParent = ((ITool)oSuper).getParent();
        else {
          oParent = null;
        }
      }
     
      if ((oParent != null) && ((oParent instanceof IToolChain))) {
        IToolChain oToolChain = (IToolChain)oParent;
        IOption[] aoOptions = oToolChain.getOptions();
   
        String sSyntaxonly = null;   
        String sDebugLevel = null;   
        String sDebugFormat = null;   
        String sDebugOther = null;   
        String sDebugProf = null;   
        String sDebugGProf = null;
        
        boolean hasRVA     = false;
        boolean hasRVC     = false;
        boolean hasRVM     = false;
        boolean hasRVF     = false;
        boolean hasRVD     = false;
        boolean hasRVQ     = false;
        boolean isRVE      = false;
        boolean hasSections = false;


        for (int i = 0; i < aoOptions.length; i++) {
          IOption oOption = aoOptions[i];
          String sID = oOption.getId();
   
          Object oValue = oOption.getValue();
   
          String sCommand = oOption.getCommand();
          if ((oValue instanceof String)) {
             String sVal;
             try {
               sVal = oOption.getStringValue();
             }
             catch (BuildException e) {
               sVal = null;
             }
             String sEnumCommand;
             try {
               sEnumCommand = oOption.getEnumCommand(sVal);
             }
             catch (BuildException e1) {
               sEnumCommand = null;
             }

             if (sID.indexOf(".option.target.processor") > 0) {
               sProcessor = sVal; //not sEnumCommand, no -m32 or -,64 anymore
             } else if (sID.indexOf(".option.target.abi") > 0) {
               sABI = sEnumCommand;
             } else if (sID.indexOf(".option.warnings.syntax") > 0) {
               sSyntaxonly = sEnumCommand;
             } else if (sID.indexOf(".option.debugging.level") > 0) {
               sDebugLevel = sEnumCommand;
             } else if (sID.indexOf(".option.debugging.format") > 0) {
               sDebugFormat = sEnumCommand;
             } else if (sID.indexOf(".option.debugging.other") > 0) {
               sDebugOther = sVal;
             } 
          }
          else if ((oValue instanceof Boolean)) {
            boolean bVal;
            try {
              bVal = oOption.getBooleanValue();
            }
            catch (BuildException e) {
             bVal = false;
            }

            if (bVal) {   
                if (sID.indexOf(".option.debugging.prof") > 0) {
                    sDebugProf = sCommand;
                } else if (sID.indexOf(".option.target.arch.rvm") > 0 ) {
                    hasRVM = true;                    
                } else if (sID.indexOf(".option.target.arch.rva") > 0 ) {
                    hasRVA = true;
                } else if (sID.indexOf(".option.target.arch.rvf") > 0 ) {
                    hasRVF = true;
                } else if (sID.indexOf(".option.target.arch.rvd") > 0 ) {
                	hasRVD = true;
                } else if (sID.indexOf(".option.target.arch.rvq") > 0 ) {
                	hasRVQ = true;                 
                } else if (sID.indexOf(".option.target.arch.rvc") > 0 ) {
                    hasRVC = true;
                } else if (sID.indexOf(".option.target.arch.rve") > 0 ) {
                    isRVE = true;
                } else if (sID.indexOf(".option.debugging.gprof") > 0) {
                    sDebugGProf = sCommand;
/* These are not ToolChain options
 * TODO determine how to query these
                } else if (sID.indexOf(".option.optimization.functionsections") > 0) {
                	hasSections = true;
                } else if (sID.indexOf(".option.optimization.datasections") > 0) {
                	hasSections = true;
*/
                }
            }
          }
        } //next i
        
        //Linker options
//        if (hasSections) oList_linker_options.add("-gc-sections");
//        oList_linker_options.add("-Wl,-gc-sections");
        
        //create sArch string ... GCC expects specific order
        if (hasRVM) sArch = sArch.concat("m");
        if (hasRVA) sArch = sArch.concat("a");
        if (hasRVF) {
        	sArch = sArch.concat("f");
            if (hasRVD) sArch = sArch.concat("d");
            if (hasRVQ) sArch = sArch.concat("q");
        }
        if (hasRVC) sArch = sArch.concat("c");
        if (isRVE ) sArch = sArch.concat("e");
        
        
        //Create Tool options
        if (sABI != null && !sABI.isEmpty())
        	oList.add(sABI);
        if (sSyntaxonly != null && !sSyntaxonly.isEmpty())
            oList.add(sSyntaxonly);
        if (sDebugLevel != null && !sDebugLevel.isEmpty()) {
            oList.add(sDebugLevel);
            if (sDebugFormat != null && !sDebugFormat.isEmpty())
              oList.add(sDebugFormat);
        }
        if (sDebugOther != null && !sDebugOther.isEmpty())
            oList.add(sDebugOther);
        if (sDebugProf != null && !sDebugProf.isEmpty())
            oList.add(sDebugProf);
        if (sDebugGProf != null && !sDebugGProf.isEmpty())
            oList.add(sDebugGProf);
      }
      
      
      //Create RISC-V command line arguments
      if (sProcessor != null && !sProcessor.isEmpty()) {
         if (sProcessor.contains("64")) {
           sArch = "-march=rv64i" + sArch;
         } else {
           sArch = "-march=rv32i" + sArch;
         }
      }
      oList.add(sArch);
      sAssemblerWaOptions = sAssemblerWaOptions + "," + sArch;

     
      if (!sAssemblerWaOptions.contentEquals(""))
    	  oList_assembler_options.add("-Wa"+sAssemblerWaOptions);
      if (!sLinkerWlOptions.contentEquals(""))
    	  oList_linker_options.add("-Wl"+sLinkerWlOptions);
      

      //Add options/parameters to command line
      oList.addAll(Arrays.asList(asFlags));
      if (bIsCompiler)
          oList.addAll(oList_compiler_options);
      if (bIsAssembler)
    	  oList.addAll(oList_assembler_options);
      if (bIsLinker)
    	  oList.addAll(oList_linker_options);

      return super.generateCommandLineInfo(oTool, sCommandName,
                (String[]) oList.toArray(new String[0]), sOutputFlag, sOutputPrefix, sOutputName,
                asInputResources, sCommandLinePattern);
    }
    
}

