package cmd

import (
	"os"

	"github.com/PerMalmberg/du-render/svg2layout/convert"
	"github.com/spf13/cobra"
)

// rootCmd represents the base command when called without any subcommands
var rootCmd = &cobra.Command{
	Use:   "SvgToLayout",
	Short: "Convert SVGs to a du-render layout",
	Long:  `Takes one or more SVGs and outputs a layout file for use with du-render`,
	// Uncomment the following line if your bare application
	// has an action associated with it:
	// Run: func(cmd *cobra.Command, args []string) { },
}

// Execute adds all child commands to the root command and sets flags appropriately.
// This is called by main.main(). It only needs to happen once to the rootCmd.
func Execute() {
	err := rootCmd.Execute()
	if err != nil {
		os.Exit(1)
	}
}

func init() {
	// Here you will define your flags and configuration settings.
	// Cobra supports persistent flags, which, if defined here,
	// will be global for your application.

	// rootCmd.PersistentFlags().StringVar(&cfgFile, "config", "", "config file (default is $HOME/.SvgToLayout.yaml)")

	// Cobra also supports local flags, which will only run
	// when this action is called directly.
	//rootCmd.Flags().BoolP("toggle", "t", false, "Help message for toggle")

	var (
		inputFiles []string
		outputFile string
	)
	convert := &cobra.Command{
		Use: "convert",
		RunE: func(cmd *cobra.Command, args []string) error {
			c := convert.NewConverter(outputFile, inputFiles...)
			return c.Convert()
		},
	}

	convert.Flags().StringArrayVar(&inputFiles, "input", []string{}, "Specify files to be converted")
	convert.Flags().StringVar(&outputFile, "output", "", "Name of output file")
	convert.MarkFlagRequired("input")
	convert.MarkFlagRequired("output")

	rootCmd.AddCommand(convert)
}
