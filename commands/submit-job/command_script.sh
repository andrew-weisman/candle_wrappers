#!/bin/bash

# If a job is requested to be submitted, do so
# Note that this script basically echos "bash run_workflows.sh" into a script and then runs that script, i.e., this script calls run_workflows.sh
# ASSUMPTIONS:
#   (1) candle module has been loaded
#   (2) the candle program has been called normally (so that the $CANDLE_SUBMISSION_DIR variable has been defined)


# Function to extract particular sections (case-insensitive) from the input file
function extract_section() {
    section_name=$1
    input_file=$2
    awk -v section_name="$section_name" 'BEGIN{do_print=0; regex_start="^&"section_name"$"; regex_end="^/$"} {if($0~regex_end)do_print=0; if(do_print){sub(/^ +/,"",$0); print}; if(tolower($0)~regex_start)do_print=1}' "$input_file"
}


# Generate the three input files (the submission script, and, if necessary, the default model and parameter space files), and execute the submission script
function generate_input_files_and_run() {

    # Get rid of comment lines and sections
    input_argument=$1
    grep -E -v "^#" "$input_argument" | awk -v FS="#" '{print $1}' > tmp_input_file.in
    input_file="tmp_input_file.in" # comment-free submission file

    # Ensure the generated_files directory has been created
    # shellcheck source=/dev/null
    source "$CANDLE/wrappers/utilities.sh"; make_generated_files_dir

    # Create the beginning part of the Bash submission script from all the keywords set in the &control section
    fn_submission_script="$CANDLE_SUBMISSION_DIR/candle_generated_files/submit_candle_job.sh"
    extract_section "control" "$input_file" | awk -v FS="=" '{loc=index($0,"="); key=$1; val=substr($0,loc+1); gsub(/ /,"",key); gsub(/^ */,"",val); print "export CANDLE_KEYWORD_" toupper(key) "=" val}' > "$fn_submission_script"

    # Define the default model file in the submission script and if required, create it
    if (extract_section "default_model" "$input_file" | head -n 1 | awk '{gsub(/[\t ]*/,""); print}' | grep -i "^candle_default_model_file=" > /dev/null); then
        # Default model keyword is present
        extract_section "default_model" "$input_file" | head -n 1 | awk '{loc=index($0,"="); val=substr($0,loc+1); gsub(/^[\t ]+|[\t ]+$/,"",val); gsub(/^[\047\042]|[\047\042]$/,"",val); print "export CANDLE_KEYWORD_DEFAULT_MODEL_FILE" "=\"" val "\""}' >> "$fn_submission_script"
    else
        # Default model keyword is NOT present

        # Define the default model filename and export it inside the submission script
        fn_default_model_file="$CANDLE_SUBMISSION_DIR/candle_generated_files/default_model.txt"
        echo "export CANDLE_DEFAULT_MODEL_FILE=\"$fn_default_model_file\"" >> "$fn_submission_script"

        # Generate the default model file
        (
            echo "[Global Params]"
            extract_section "default_model" "$input_file"
        ) > "$fn_default_model_file"
    fi

    # Define the parameter space file in the submission script and if required, create it
    if (extract_section "param_space" "$input_file" | head -n 1 | awk '{gsub(/[\t ]*/,""); print}' | grep -i "^candle_param_space_file=" > /dev/null); then
        # Parameter space keyword is present
        extract_section "param_space" "$input_file" | head -n 1 | awk '{loc=index($0,"="); val=substr($0,loc+1); gsub(/^[\t ]+|[\t ]+$/,"",val); gsub(/^[\047\042]|[\047\042]$/,"",val); print "export CANDLE_KEYWORD_PARAM_SPACE_FILE" "=\"" val "\""}' >> "$fn_submission_script"
    else
        # Parameter space keyword is NOT present

        # Define the parameter space filename and export it inside the submission script
        workflow=$(grep "^export CANDLE_KEYWORD_WORKFLOW=" "$fn_submission_script" | awk -v FS="=" '{gsub(/"/,""); print tolower($2)}')
        if [ "a$workflow" == "agrid" ]; then
            wsf_ext="txt"
        else
            wsf_ext="R"
        fi
        fn_param_space_file="$CANDLE_SUBMISSION_DIR/candle_generated_files/${workflow}_workflow.${wsf_ext}"
        echo "export CANDLE_WORKFLOW_SETTINGS_FILE=\"$fn_param_space_file\"" >> "$fn_submission_script"

        # Generate the parameter space file
        extract_section "param_space" "$input_file" > tmp.txt
        nlines=$(wc -l tmp.txt | awk '{print $1}')
        (
            if [ "a$workflow" == "agrid" ]; then
                cat tmp.txt
            else
                echo "param.set <- makeParamSet("
                awk -v nlines="$nlines" '{if(NR<nlines){print $0 ","} else{print $0}}' tmp.txt
                echo ")"
            fi
        ) > "$fn_param_space_file"
        rm -f tmp.txt
    fi

    # Wrap up the submission file by running run_workflows.sh
    echo "bash \$CANDLE/wrappers/commands/submit-job/run_workflows.sh" >> "$fn_submission_script"

    # Delete comment-free input file
    rm -f $input_file

    # Run the submission script
    bash "$fn_submission_script"

}


# The .in file should be the argument to this script
input_file=$1

# This is not actually used in the wrappers but is useful to reference in Supervisor (see e.g. workflows/common/sh/utils.sh)
export CANDLE_INPUT_FILE=$(readlink -e "$input_file")

# Generate the three input files from this single input file and then execute the generated submission script
echo "Submitting the CANDLE input file \"$input_file\"... "
generate_input_files_and_run "$input_file" && echo "Input file submitted successfully" || echo "Input file submission failed"
