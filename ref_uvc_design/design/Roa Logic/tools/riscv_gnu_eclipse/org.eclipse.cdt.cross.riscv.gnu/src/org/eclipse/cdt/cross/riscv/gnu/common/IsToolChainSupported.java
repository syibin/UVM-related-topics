/*******************************************************************************
 * This program and the accompanying materials 
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 * 
 * Contributors:
 *   RoaLogic BV - RISC-V Gnu Toolchain port
 *******************************************************************************/

package org.eclipse.cdt.cross.riscv.gnu.common;

import java.io.File;
import java.util.Arrays;
import java.util.List;

import org.eclipse.cdt.managedbuilder.core.IManagedIsToolChainSupported;
import org.eclipse.cdt.managedbuilder.core.ITool;
import org.eclipse.cdt.managedbuilder.core.IToolChain;
import org.eclipse.core.runtime.Platform;
import org.osgi.framework.Version;

public abstract class IsToolChainSupported implements IManagedIsToolChainSupported {
    static final boolean DEBUG = false;

    public String getCompilerName() {
        return "riscv64-unknown-elf-gcc";
    }

    public String getPlatform() {
        return "linux";
    }

    public boolean isSupportedImpl(IToolChain oToolChain, Version oVersion,
            String sInstance, IsToolchainData oStaticData) {
        ITool[] tools = oToolChain.getTools();
        for (ITool tool : tools) {
            String extensions[] = tool.getAllOutputExtensions();
            List<String> extList = Arrays.asList(extensions);
            if (extList.contains("o") || extList.contains("obj")) {
                // We assume this tool is the compiler if its output
                // is .o or .obj file.
                // If the compiler doesn't exist in the search path,
                // then we don't support the tool.
                String cmd = tool.getToolCommand();
                if (cmd != null && cmd.length() > 0) {
                    if (!CommandInfo.commandExists(cmd))
                        return false;
                }
            }

            String current_tool_command = tool.getToolCommand();
            if (CommandInfo.commandExistsInPredefinedPath(current_tool_command)) {
                String eclipsehome = Platform.getInstallLocation().getURL().getPath();
                File predefined_path_dir = new File(eclipsehome).getParentFile();
                String predefined_path = predefined_path_dir + File.separator
                        + "bin" + File.separator;
                if (current_tool_command.indexOf(predefined_path) < 0) {
                    tool.setToolCommand(predefined_path + current_tool_command);
                }
            }
        }

        return true;
    }
}
