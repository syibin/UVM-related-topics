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
package com.riscv.cdt.toolchain;

import org.eclipse.cdt.managedbuilder.core.IBuildObject;
import org.eclipse.cdt.managedbuilder.core.IConfiguration;
import org.eclipse.cdt.managedbuilder.core.IHoldsOptions;
import org.eclipse.cdt.managedbuilder.core.IOption;
import org.eclipse.cdt.managedbuilder.core.IOptionApplicability;
import org.eclipse.cdt.managedbuilder.core.IToolChain;


public class ApplicabilityCalculator implements IOptionApplicability {

    // There is one instance of this class per option. But we want
    // to share the same enablement manager. So make it static.
    private static final OptionEnablementManager EMGR = new OptionEnablementManager();
    private  static IBuildObject lastConfig;
    //cr92699: toolchain can change, but same configuration is used!
    private static IToolChain lastToolchain;
    
    public boolean isOptionUsedInCommandLine (IBuildObject configuration, IHoldsOptions holder, IOption option) {
        return isOptionEnabled(configuration,holder,option);       
    }

    public boolean isOptionVisible (IBuildObject configuration, IHoldsOptions holder, IOption option) {
        return true;
    }
    
    public static AbstractOptionEnablementManager getOptionEnablementManager(){
        return EMGR;
    }

    public boolean isOptionEnabled (IBuildObject configuration, IHoldsOptions holder, IOption option) {
        // Since there are no listeners on option changes,
        // we must resort to reading the states of all options!!!
        IToolChain toolchain = null;
        if (configuration instanceof IConfiguration){
            toolchain = ((IConfiguration)configuration).getToolChain();
        }
        if (configuration != lastConfig || toolchain != lastToolchain) {
            lastConfig = configuration;
            lastToolchain = toolchain;
            EMGR.initialize(configuration);
        }
        return EMGR.isEnabled(option.getBaseId());
    }
    
}
