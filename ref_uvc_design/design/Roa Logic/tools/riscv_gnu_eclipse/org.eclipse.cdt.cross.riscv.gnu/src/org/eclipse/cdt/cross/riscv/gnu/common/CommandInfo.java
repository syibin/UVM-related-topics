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

import org.eclipse.core.runtime.Platform;


/**
 * A method for determining if a command exists under JRE 1.5 or later.
 * <P>
 * CUSTOMIZATION
 * <P>
 * @author David Pickens
 */
public class CommandInfo {

    /**
     * Return whether or not a command exists.
     * <P>
     * Called to determine if a toolchain is supported.
     * @param cmd the command
     * @return whether or not a command exists.
     */
    public static boolean commandExists(String cmd) {
        cmd = normalizeCommand(cmd);
        
        File f = new File(cmd);
        if (f.isAbsolute())
            return f.exists();
        
        return commandExistsInSystemPath(cmd) || commandExistsInPredefinedPath(cmd);
    }
    
    private static String normalizeCommand(String cmd) {
        // There may be arguments so only grab up to the whitespace
        if (cmd.indexOf(' ') > 0)
            cmd = cmd.substring(0, cmd.indexOf(' '));
        if (isWindows() && !cmd.toLowerCase().endsWith(".exe"))
            cmd = cmd + ".exe";
        return cmd;
    }
    
    public static boolean commandExistsInSystemPath(String cmd) {
        cmd = normalizeCommand(cmd);
        
        // Checking for compiler presence in PATH.
        String path = System.getenv("PATH");
        if (path != null) {
            String paths[] = path.split(File.pathSeparator);
            for (String p : paths) {
                if (new File(p, cmd).isFile())
                    return true;
            }
        }
        
        return false;
    }
    
    public static boolean commandExistsInPredefinedPath(String cmd) {
        cmd = normalizeCommand(cmd);
        
        // Checking for compiler presence in location ../bin relative to eclipse.exe.
        // So IDE releases will work even when PATH is not configured
        String eclipsehome = Platform.getInstallLocation().getURL().getPath();
        File predefined_path_dir = new File(eclipsehome).getParentFile();
        String predefined_path = predefined_path_dir + File.separator + "bin";
        return new File(predefined_path, cmd).isFile();
    }
    
    /**
     * Determine whether or not we're running on Microsoft Windows.
     * @return true if we're running under Microsoft Windows.
     */
    public static boolean isWindows() {
        return System.getProperty("os.name").indexOf("indow") > 0;
    }

}
