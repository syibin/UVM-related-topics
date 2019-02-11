/*******************************************************************************
 * Copyright (c) 2016 RoaLogic BV
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 * Synopsys, Inc. - Initial implementation
 * Synopsys, Inc. - ARC GNU Toolchain support
 * RoaLogic BV    - RISC-V Gnu Toolchain port
 *******************************************************************************/
package com.riscv.cdt.toolchain.riscv;

import java.util.ArrayList;
import java.util.List;

import org.eclipse.cdt.managedbuilder.core.IOption;
import org.eclipse.cdt.managedbuilder.core.ITool;

import com.riscv.cdt.toolchain.IOptionEnablementManager;
import com.riscv.cdt.toolchain.OptionEnablementManager;

public class RISCVOptionEnablementManager extends OptionEnablementManager {

	private static final String RVF_OPTION_ID = "org.eclipse.cdt.cross.riscv.gnu.base.option.target.arch.rvf";
	private static final String RVD_OPTION_ID = "org.eclipse.cdt.cross.riscv.gnu.base.option.target.arch.rvd";
	private static final String RVQ_OPTION_ID = "org.eclipse.cdt.cross.riscv.gnu.base.option.target.arch.rvq";
	
	//for some reason FDIV doesn't work ... fixed in RISCVManagedCommandLineGenerator
	private static final String FDIV_OPTION_ID = "org.eclipse.cdt.cross.riscv.gnu.base.option.fdiv";
	
	private static final String[] DISABLE_WHEN_NO_RVF = { RVD_OPTION_ID, RVQ_OPTION_ID, FDIV_OPTION_ID };
	private static final String[] DISABLE_WHEN_NO_RVD = { RVQ_OPTION_ID };
	

    private List<String> targetOptions;

    public RISCVOptionEnablementManager() {
        addObserver(new Observer());
    }

    private boolean rvfValue;
    private boolean rvdValue;

    private void readTargetOptions() {
        targetOptions = new ArrayList<String>();
        for (IOption option : getToolChain().getOptions()) {
            if (option.getCategory().getBaseId().contains("category.target")) {
                targetOptions.add(option.getBaseId());
            }
        }
    }

    private List<String> getToolChainSpecificOption(String optionId) {
        List<String> list = new ArrayList<String>();
        for (IOption option : getToolChain().getOptions()) {
            IOption tmp = option;
            while (tmp != null) {
                if (tmp.getBaseId().equals(optionId)) {
                    list.add(option.getBaseId());
                }
                tmp = tmp.getSuperClass();
            }
        }
        for (ITool tool : getToolChain().getTools()) {
            for (IOption option : tool.getOptions()) {
                IOption tmp = option;
                while (tmp != null) {
                    if (tmp.getBaseId().equals(optionId)) {
                        list.add(option.getBaseId());
                    }
                    tmp = tmp.getSuperClass();
                }
            }
        }
        return list;
    }

    class Observer implements IOptionEnablementManager.IObserver {

        /**
         * Called when an option value changes. Enable or disable any options that are dependent on
         * this one.
         * 
         * @param mgr
         * @param optionId
         */
        public void onOptionValueChanged(IOptionEnablementManager mgr, String optionId) {
            // `contains()` because sometimes this options has numeric suffix in the end.
            if (optionId.contains("option.target.arch")) {
                readTargetOptions();
            }
            if (optionId.contains("option.target.arch.rvf")) {
                rvfValue = (Boolean) mgr.getValue(optionId);
                if (rvfValue) {
                	//enable options when RVF is selected
                    for (String option : DISABLE_WHEN_NO_RVF) {
                        setEnabled(getToolChainSpecificOption(option), true);
                    }
                } else {
                	//disable specific options
                	for (String option: DISABLE_WHEN_NO_RVF) {
                        setEnabled(getToolChainSpecificOption(option),false);
                    }
                }  
            }
            if (optionId.contains("option.target.arch.rvd")) {
                rvdValue = (Boolean) mgr.getValue(optionId);
                if (rvdValue) {
                	//enable options when RVF is selected
                    for (String option : DISABLE_WHEN_NO_RVD) {
//                        setEnabled(getToolChainSpecificOption(option), true);
                    }
                } else {
                	//disable specific options
                	for (String option: DISABLE_WHEN_NO_RVD) {
//                		setEnabled(getToolChainSpecificOption(option),false);
                    }
                }  
            }
        }

        public void onOptionEnablementChanged(IOptionEnablementManager mgr, String optionId) {
        	/*
            if (optionId.contains("option.target.arch")) {
                readTargetOptions();
            }
            if (optionId.contains("option.target.arch.rvd")) {
                rvdValue = (Boolean) mgr.getValue(optionId);
                if (rvdValue) {
                	//enable options when RVF is selected
                    for (String option : DISABLE_WHEN_NO_RVD) {
                        setEnabled(getToolChainSpecificOption(option), true);
                    }
                } else {
                	//disable specific options
                	for (String option: DISABLE_WHEN_NO_RVD) {
                		setEnabled(getToolChainSpecificOption(option),false);
                    }
                }  
            }
            */
        }
    }
}
