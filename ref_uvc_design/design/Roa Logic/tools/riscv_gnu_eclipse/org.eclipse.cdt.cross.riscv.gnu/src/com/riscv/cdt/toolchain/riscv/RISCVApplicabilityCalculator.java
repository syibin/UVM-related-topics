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

import org.eclipse.cdt.managedbuilder.core.IBuildObject;
import org.eclipse.cdt.managedbuilder.core.IHoldsOptions;
import org.eclipse.cdt.managedbuilder.core.IOption;
import org.eclipse.cdt.managedbuilder.core.IOptionApplicability;



public class RISCVApplicabilityCalculator implements IOptionApplicability {

	public RISCVApplicabilityCalculator(){}
	// There is one instance of this class per option. But we want
    // to share the same enablement manager. So make it static.
    private static final RISCVOptionEnablementManager EMGR = new RISCVOptionEnablementManager();
    private static IBuildObject lastConfig;
    
    public boolean isOptionUsedInCommandLine (IBuildObject configuration, IHoldsOptions holder, IOption option) {
        return isOptionEnabled(configuration,holder,option);       
    }

    public boolean isOptionVisible (IBuildObject configuration, IHoldsOptions holder, IOption option) {
        return true;
    }

    public boolean isOptionEnabled (IBuildObject configuration, IHoldsOptions holder, IOption option) {
        // Since there are no listeners on option changes,
        // we must resort to reading the states of all options!!!
        if (configuration != lastConfig) {
            lastConfig = configuration;
            EMGR.initialize(configuration);
        }
        
        // Some options are not in configuration and will not be copied in
        // `initialize()` (I don't know why). So to ensure consistency, here
        // we will add them to the manager.
        if (option.getValue() != EMGR.getValue(option.getId())) {
        	EMGR.set(option.getId(), option.getValue());
        }
        return EMGR.isEnabled(option.getBaseId());
    }
    
}

