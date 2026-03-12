package org.jasypt.intf.cli;

import org.jasypt.commons.CommonUtils;
import org.jasypt.intf.service.JasyptStatelessService;

import java.util.Properties;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class JasyptPBEFileTokenEncryptionCLI {
    private static final JasyptStatelessService SERVICE = new JasyptStatelessService();

    /*
     * The required arguments for this CLI operation.
     */
    private static final String[][] VALID_REQUIRED_ARGUMENTS =
            new String[][] {
                    new String [] {
                            ArgumentNaming.ARG_FILE_PATH
                    },
                    new String [] {
                            ArgumentNaming.ARG_PASSWORD
                    }
            };

    /*
     * The optional arguments for this CLI operation.
     */
    private static final String[][] VALID_OPTIONAL_ARGUMENTS =
            new String[][] {
                    new String [] {
                            ArgumentNaming.ARG_VERBOSE
                    },
                    new String [] {
                            ArgumentNaming.ARG_ALGORITHM
                    },
                    new String [] {
                            ArgumentNaming.ARG_KEY_OBTENTION_ITERATIONS
                    },
                    new String [] {
                            ArgumentNaming.ARG_SALT_GENERATOR_CLASS_NAME
                    },
                    new String [] {
                            ArgumentNaming.ARG_PROVIDER_NAME
                    },
                    new String [] {
                            ArgumentNaming.ARG_PROVIDER_CLASS_NAME
                    },
                    new String [] {
                            ArgumentNaming.ARG_STRING_OUTPUT_TYPE
                    },
                    new String[] {
                            ArgumentNaming.ARG_IV_GENERATOR_CLASS_NAME
                    },
                    new String[] {
                            ArgumentNaming.ARG_FILE_CHARSET
                    }
            };

    /**
     * <p>
     * CLI execution method.
     * </p>
     *
     * @param args the command execution arguments
     */
    public static void main(final String[] args) {

        final boolean verbose = CLIUtils.getVerbosity(args);

        try {
            String applicationName;
            String[] arguments;
            if (args[0] == null || args[0].contains("=")) {
                applicationName = JasyptPBEFileTokenEncryptionCLI.class.getName();
                arguments = args;
            } else {
                applicationName = args[0];
                arguments = new String[args.length - 1];
                System.arraycopy(args, 1, arguments, 0, args.length - 1);
            }

            final Properties argumentValues =
                    CLIUtils.getArgumentValues(
                            applicationName, arguments,
                            VALID_REQUIRED_ARGUMENTS, VALID_OPTIONAL_ARGUMENTS);

            CLIUtils.showEnvironment(verbose);
            CLIUtils.showArgumentDescription(argumentValues, verbose);

            String charsetName = argumentValues.getProperty(ArgumentNaming.ARG_FILE_CHARSET, "UTF-8");
            String filePath = argumentValues.getProperty(ArgumentNaming.ARG_FILE_PATH);
            String text = CommonUtils.readFileToString(filePath, charsetName);

            Pattern pattern = Pattern.compile("(?i)DEC\\(([^\\r\\n]+)\\)");
            Matcher matcher = pattern.matcher(text);
            StringBuffer buffer = new StringBuffer();
            while (matcher.find()) {
                String decrypted = matcher.group(1);
                String replacement = "ENC(" + encrypt(decrypted, argumentValues) + ")";
                matcher.appendReplacement(buffer, Matcher.quoteReplacement(replacement));
            }
            matcher.appendTail(buffer);

            String result = buffer.toString();
            CommonUtils.writeStringToFile(filePath, result, charsetName);
            CLIUtils.showOutput("Done!", verbose);
        } catch (Throwable t) {
            CLIUtils.showError(t, verbose);
        }

    }

    private static String encrypt(String input, Properties argumentValues) {
        return SERVICE.encrypt(
                input,
                argumentValues.getProperty(ArgumentNaming.ARG_PASSWORD),
                null,
                null,
                argumentValues.getProperty(ArgumentNaming.ARG_ALGORITHM),
                null,
                null,
                argumentValues.getProperty(ArgumentNaming.ARG_KEY_OBTENTION_ITERATIONS),
                null,
                null,
                argumentValues.getProperty(ArgumentNaming.ARG_SALT_GENERATOR_CLASS_NAME),
                null,
                null,
                argumentValues.getProperty(ArgumentNaming.ARG_PROVIDER_NAME),
                null,
                null,
                argumentValues.getProperty(ArgumentNaming.ARG_PROVIDER_CLASS_NAME),
                null,
                null,
                argumentValues.getProperty(ArgumentNaming.ARG_STRING_OUTPUT_TYPE),
                null,
                null,
                argumentValues.getProperty(ArgumentNaming.ARG_IV_GENERATOR_CLASS_NAME),
                null,
                null);
    }

    /*
     * Instantiation is forbidden.
     */
    private JasyptPBEFileTokenEncryptionCLI() {
        super();
    }

}
