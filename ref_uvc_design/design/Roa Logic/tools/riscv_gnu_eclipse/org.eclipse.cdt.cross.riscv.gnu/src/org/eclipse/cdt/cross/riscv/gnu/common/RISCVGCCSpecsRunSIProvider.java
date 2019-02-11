/*******************************************************************************
 * Copyright (c) 2016 RoaLogic BV
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *   RoaLogic BV - Initial implementation 
 *******************************************************************************/

package org.eclipse.cdt.cross.riscv.gnu.common;

import java.io.File;
import java.util.Properties;

import org.eclipse.cdt.core.ICommandLauncher;
import org.eclipse.cdt.make.internal.core.scannerconfig2.GCCSpecsRunSIProvider;
import org.eclipse.core.runtime.Platform;

@SuppressWarnings("restriction")
public class RISCVGCCSpecsRunSIProvider extends GCCSpecsRunSIProvider {

    @Override
    protected String[] setEnvironment(ICommandLauncher launcher, Properties initialEnv) {
        // Ensure that we have properties.
        Properties props = initialEnv != null ? initialEnv : launcher.getEnvironment();
        
        // Get an absolute path to ../bin.
        String eclipsehome = Platform.getInstallLocation().getURL().getPath();
        File predefined_path_dir = new File(eclipsehome).getParentFile();
        String predefined_path = predefined_path_dir + File.separator + "bin"+File.separator;
        
        // Append ../bin to PATH.
        if(props!=null){
        String path = props.getProperty("PATH");
        if (path!=null&& !path.endsWith(predefined_path)) {
            path = path + File.pathSeparatorChar + predefined_path;
            props.setProperty("PATH", path);
        }
        }
        
        // Use super-class method to do the rest.
        return super.setEnvironment(launcher, initialEnv);
    }

}
