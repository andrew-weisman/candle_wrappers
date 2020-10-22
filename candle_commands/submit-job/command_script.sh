#!/bin/bash

# If a job is requested to be submitted, do so
# Note that this script basically echos run_workflows.sh into a script and then runs that script, i.e., this script calls run_workflows.sh
# ASSUMPTIONS: candle module is loaded

# Function to extract particular sections from the input file
function extract_section() {
    section_name=$1
    submission_file=$2
    awk -v section_name="$section_name" 'BEGIN{do_print=0; regex_start="^&"section_name"$"; regex_end="^/$"} {if($0~regex_end)do_print=0; if(do_print){sub(/^ +/,"",$0); print}; if($0~regex_start)do_print=1}' "$submission_file"
}

function generate_input_files_and_run() {
    submission_file=$1

    # Ensure the generated_files directory has been created
    # shellcheck source=/dev/null
    source "$CANDLE/wrappers/utilities.sh"; make_generated_files_dir

    # Get the filenames of two of the three generated input files
    fn_submission_script="./candle_generated_files/submit_candle_job.sh"
    fn_default_model="./candle_generated_files/default_model.txt"

    # Generate an "almost" version of the submission script, stored in tmp.txt
    (
        echo "#!/bin/bash"
        extract_section "control" "$submission_file" | awk -v FS="=" '{loc=index($0,"="); key=$1; val=substr($0,loc+1); gsub(/ /,"",key); gsub(/^ */,"",val); print "export CANDLE_KEYWORD_" toupper(key) "=" val}'
        echo "\$CANDLE/wrappers/candle_commands/submit-job/run_workflows.sh"
    ) > tmp.txt

    # Extract everything but the WORKFLOW line into tmp2.txt and insert everything up to that line into the generated submission script
    cp tmp.txt tmp2.txt
    split_line=$(awk 'BEGIN{regex="^export MODEL_SCRIPT=\""} {if($0~regex)print NR}' tmp2.txt)
    awk -v split_line="$split_line" '{if(NR<=split_line)print}' tmp2.txt > $fn_submission_script

    # From the WORKFLOW line determine filename of the third generated input file
    workflow=$(grep "^export WORKFLOW=\"" tmp.txt | awk -v FS="=" '{gsub(/"/,""); print tolower($2)}')
    if [ "a$workflow" == "agrid" ]; then
        wsf_ext="txt"
    else
        wsf_ext="R"
    fi
    fn_workflow_settings_file="./candle_generated_files/${workflow}_workflow.${wsf_ext}"

    # Insert the other two generated input filename settings into the generated submission script
    path_or_not="$(pwd)/"
    (
        echo "export CANDLE_DEFAULT_MODEL_FILE=\"$(pwd)/${fn_default_model}\"" # must be a full path in order to find the default settings
        echo "export WORKFLOW_SETTINGS_FILE=\"${path_or_not}${fn_workflow_settings_file}\"" # can no longer be a full path in recent develop version of CANDLE
        awk -v split_line="$split_line" '{if(NR>split_line)print}' tmp2.txt # populate the rest of the submission script and make it executable
    ) >> $fn_submission_script
    chmod u+x $fn_submission_script

    # Generate the default parameters file
    (
        echo "[Global Params]"
        extract_section "default_model" "$submission_file"
    ) > $fn_default_model

    # Generate the workflow settings file
    extract_section "param_space" "$submission_file" > tmp3.txt
    nlines=$(wc -l tmp3.txt | awk '{print $1}')
    (
        if [ "a$workflow" == "agrid" ]; then
            cat tmp3.txt
        else
            echo "param.set <- makeParamSet("
            awk -v nlines="$nlines" '{if(NR<nlines){print $0 ","} else{print $0}}' tmp3.txt
            echo ")"
        fi
    ) > "$fn_workflow_settings_file"

    rm -f tmp.txt tmp2.txt tmp3.txt

    # Run the submission script
    ./$fn_submission_script
}


# Input parameter "submission_file"
submission_file=$1

# Determine the extension of the submission file
extension=$(echo "$submission_file" | awk -v FS="." '{print tolower($NF)}')

# If the submission file is .sh, execute this submission script...
if [ "a$extension" == "ash" ]; then
    submission_file2="$(dirname "$submission_file")/$(basename "$submission_file")"
    echo "Submitting the CANDLE submission script \"$submission_file2\"... "
    $submission_file2 && echo "done" || echo "failed"

# ...if the submission file is .in, first generate the input files from this single input file, and then execute the generated submission script...
elif [ "a$extension" == "ain" ]; then
    echo "Submitting the CANDLE input file \"$submission_file\"... "
    export CANDLE_INPUT_FILE="$submission_file"
    generate_input_files_and_run "$submission_file" && echo "done" || echo "failed"

# ...otherwise, throw an error
else
    echo "ERROR: Unknown extension ($extension) of submission file $submission_file"
    exit
fi
