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

public interface IOptionEnablementManager {
    interface IObserver {
        /**
         * Called when an option value changes, whether explicitly
         * or implicitly.
         * @param mgr the manager that is being observed.
         * @param optionId the id of the option that changed.
         */
        void onOptionValueChanged(IOptionEnablementManager mgr, String optionId);
        /**
         * 
         * Called when the enabled property of an option changes.
         * @param mgr the manager that is being observed.
         * @param optionID the id of the option.
         */
        void onOptionEnablementChanged(IOptionEnablementManager mgr, String optionID);
    }
    /**
     * Initialize to the current state of a configuration.
     * @param config either an instance of ICOnfiguration or IResourceConfiguration.
     */
    public void initialize(IBuildObject config);
    /**
     * Initially called to record an option value, given
     * its ID. Subsequently, this method is called from the
     * UI as options are set. Any side-effects (e.g. changing
     * the enablement of other options) materialize by
     * notifying observers.
     * @param optionId the generic ID of an option.
     * @param value the value of the option.
     */
    public void set(String optionId, Object value);
    
    /**
     * Return the current value of an option, given the option's id.
     * @param optionId the id of the option.
     * @return the value of the option, or <code>null</code> if option
     * is not recognized.
     */
    public Object getValue(String optionId);
    
    /**
     * Return whether or not the given ID is enabled, given
     * the setting of things.
     * @param optionId the generic option ID to test.
     * @return true if option ID is enabled; false if disabled.
     */
    public boolean isEnabled(String optionId);
    
    /**
     * Add an observer (typically a UI property page).
     * @param observer an observer to be called when things change.
     */
    public void addObserver(IObserver observer);
    
    
    /**
     * Remove a previously-installed observer.
     * @param observer the observer to be removed.
     */
    public void removeObserver(IObserver observer);

}
