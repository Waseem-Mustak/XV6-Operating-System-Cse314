# Function to trim whitespace from a string
trim() {
    echo "$1" | sed -e 's/^[ \t\r]*//' -e 's/[ \t\r]*$//'
}

# Function to check if a directory exists
directoryExists() {
    if [ -d "$1" ]; then
        echo true
    else
        echo false
    fi
}

# Function to check if a string is a number
isNumber() {
    if [[ "$1" =~ ^[0-9]+$ ]]; then
        echo true
    else
        echo false
    fi
}

# Check if the input file is provided as a command-line argument
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 input_file.txt"
    exit 1
fi

inputFile="$1"

# Check if the provided file exists and line count
if [ ! -f "$inputFile" ]; then
    echo "Error: File '$inputFile' does not exist."
    exit 1
fi


expectedLineCount=11
actualLineCount=$(wc -l < "$inputFile")
if [ "$actualLineCount" -ne "$expectedLineCount" ]; then
    echo "Found $actualLineCount lines, expected $expectedLineCount lines."
    exit 1
fi

# Read and process the input file
fileLines=()
while IFS= read -r line; do
    trimmedLine=$(trim "$line")
    fileLines+=("$trimmedLine")
done < "$inputFile"

# Extract values from the input file
isArchivedFlag=()
archiveFormats=()
programmingLanguages=()
totalMarks=0
penaltyForUnmatchedOutput=0
assignmentDirectory=""
studentIdRange=()
expectedOutputPath=""
submissionViolationPenalty=0
plagiarismFilePath=""
plagiarismPenalty=0



# Parse and store values
IFS=' ' read -r -a isArchivedFlag <<< "${fileLines[0]}"
IFS=' ' read -r -a archiveFormats <<< "${fileLines[1]}"
IFS=' ' read -r -a programmingLanguages <<< "${fileLines[2]}"

totalMarks="${fileLines[3]}"
penaltyForUnmatchedOutput="${fileLines[4]}"
assignmentDirectory="${fileLines[5]}"
IFS=' ' read -r -a studentIdRange <<< "${fileLines[6]}"
expectedOutputPath="${fileLines[7]}"
submissionViolationPenalty="${fileLines[8]}"
plagiarismFilePath="${fileLines[9]}"
plagiarismPenalty="${fileLines[10]}"


expectedOutputFileName=$(basename "$expectedOutputPath" | cut -d'.' -f1)
expectedOutputFileName="${expectedOutputFileName%.*}"

plagiarismFilePathName=$(basename "$plagiarismFilePath" | cut -d'.' -f1)
plagiarismFilePathName="${plagiarismFilePathName%.*}"

# Validate inputs
if [ "$(isNumber "$totalMarks")" = false ]; then
    echo "Error: Total Marks is not a valid number."
    exit 1
elif [ "$(isNumber "$penaltyForUnmatchedOutput")" = false ]; then
    echo "Error: Penalty For Unmatched Output is not a valid number."
    exit 1
elif [ "$(directoryExists "$assignmentDirectory")" = false ]; then
    echo "Error: Assignment Directory does not exist."
    exit 1
elif [ "$(isNumber "$submissionViolationPenalty")" = false ]; then
    echo "Error: Submission Violation Penalty is not a valid number."
    exit 1
elif [ "$(isNumber "$plagiarismPenalty")" = false ]; then
    echo "Error: Plagiarism Penalty is not a valid number."
    exit 1
elif [ "${#studentIdRange[@]}" -ne 2 ]; then
    echo "Error: Does not have exactly 2 Student IDs."
    exit 1
elif [ "$(isNumber "${studentIdRange[0]}")" = false ]; then
    echo "Error: First Student ID in range is not a valid number."
    exit 1
elif [ "$(isNumber "${studentIdRange[1]}")" = false ]; then
    echo "Error: Second Student ID in range is not a valid number."
    exit 1
fi

echo "All the inputs are in valid format."





# task 2
mkdir -p ./home/unarchivedAssignment
mkdir -p ./issues
mkdir -p ./checked
declare -A marksForEveryStudent
declare -A remarks
allPossibleArchiveFormats=("zip" "rar" "tar" "tar.gz" "tar.bz2" "7z")


# Function to unarchive a file
unarchiveFile() {
    local file="$1"
    local fileType="$3"
    local outputDir="$2"
    case "$fileType" in
        zip)
            unzip "$file" -d "$outputDir"
            ;;
        rar)
            unrar x "$file" "$outputDir"
            ;;
        tar)
            tar -xf "$file" -C "$outputDir"
            ;;
        *)
            echo "Wrong File $fileType"
            return 1
            ;;
    esac
    return 0
}


# Process each submission
for submission in "$assignmentDirectory"/*; do
    studentID=$(basename "$submission" | cut -d'.' -f1)

    echo $studentID

    if [ "$(isNumber "$studentID")" = false ]; then
        if [ "$studentID" = "$expectedOutputFileName" ]; then
            continue
        fi
        if [ "$studentID" = "$plagiarismFilePathName" ]; then
            continue
        fi
        mv "$submission" "./issues"
        continue
    fi

    if [ $studentID -ge "${studentIdRange[0]}" ] && [ $studentID -le "${studentIdRange[1]}" ] ;then

        if [ -d "$submission" ]; then
            unarchiveDir="./home/unarchivedAssignment/$studentID";
            mkdir -p "$unarchiveDir"

            cp -r "$submission" "$unarchiveDir"

            if [ "${isArchivedFlag[0]}" = "true" ]; then
                marksForEveryStudent["$studentID"]=$((marksForEveryStudent["$studentID"] - $submissionViolationPenalty))
                remarks["$studentID"]="${remarks["$studentID"]} issue case #1"
            fi

        elif [ -f "$submission" ]; then
            fileExtension="${submission##*.}"
            if [[ " ${archiveFormats[@]} " =~ " ${fileExtension} " ]]; then
                if [ "${isArchivedFlag[0]}" = "false" ]; then
                    remarks["$studentID"]="${remarks["$studentID"]} issue case #3"
                    mv "$submission" "./issues"
                else
                    unarchiveDir="./home/unarchivedAssignment/$studentID"
                    mkdir -p "$unarchiveDir"

                    unarchiveFile "$submission" "$unarchiveDir" "$fileExtension"
                fi
            elif [[ " ${programmingLanguages[@]} " =~ " ${fileExtension} " ]]; then

                unarchiveDir="./home/unarchivedAssignment/$studentID/$studentID"
                mkdir -p "$unarchiveDir"
                cp "$submission" "$unarchiveDir"

                if [ "${isArchivedFlag[0]}" = "true" ]; then
                    marksForEveryStudent["$studentID"]=$((marksForEveryStudent["$studentID"] - $submissionViolationPenalty))
                    remarks["$studentID"]="${remarks["$studentID"]} issue case #1"
                fi

                
            elif [[ " ${allPossibleArchiveFormats[@]} " =~ " ${fileExtension} " ]]; then
                    remarks["$studentID"]="${remarks["$studentID"]} issue case #2"
                    mv "$submission" "./issues"
            else
                remarks["$studentID"]="${remarks["$studentID"]} issue case #3"
                mv "$submission" "./issues"
            fi
        fi

    else
        mv "$submission" "./issues"
        remarks["$studentID"]="${remarks["$studentID"]} issue case #5"
    fi
done


compileAndRun(){
    case "$1" in
        cpp)
            g++ -c "$2" -o "$3.o"
            g++ "$3.o" -o "$3"  
            ./"$3" > "$4"  
            ;;
        c)
            gcc -c "$2" -o "$3.o"  
            gcc "$3.o" -o "$3"
            ./"$3" > "$4" 
            ;;
        sh)
            bash "$2" > "$4"  
            ;;
        py)
            python3 "$2" > "$4"
            ;;  
        *)
            echo "Wrong File: $1"
            ;;
    esac
}


checkOutput(){
    penaltyCount=0
    allLines=()
    while IFS= read -r line
    do
        trimmedLine=$(echo "$line" | sed -e 's/^[ \t\r]*//' -e 's/[ \t\r]*$//')
        allLines+=("$trimmedLine")
    done < "$1"

    
    while IFS= read -r line
    do
        trimmedLine=$(echo "$line" | sed -e 's/^[ \t\r]*//' -e 's/[ \t\r]*$//')
        found=false
       
        for (( i=0 ; i<${#allLines[@]} ;i++))
        do  
            if [ "${allLines[$i]}" = "$trimmedLine" ] ;then
                found=true
                break
            fi
        done    

        if [ $found = "false" ] ;then
            penaltyCount=$((penaltyForUnmatched + penalty))
        fi

    done < "$expectedOutputPath"
    echo $penaltyCount
}

# Iterate over each student's folder
present_students=()
unarchivedDir="./home/unarchivedAssignment"
for submission in "$unarchivedDir"/*; do
    studentID=$(basename "$submission" | cut -d'.' -f1)
    tem_Id=$(trim "$studentID")
    present_students+=("$tem_Id")

    for submission1 in "$submission"/*; do
        studentID1=$(basename "$submission1" | cut -d'.' -f1)

        if [ "$studentID" != "$studentID1" ]; then
            marksForEveryStudent["$studentID"]=$((marksForEveryStudent["$studentID"] - $submissionViolationPenalty))
            remarks["$studentID"]="${remarks["$studentID"]} issue case #4"
        fi

        flag=0

        for submission2 in "$submission1"/*; do
            studentID2=$(basename "$submission2" | cut -d'.' -f1)
            
            if [ "$studentID" = "$studentID2" ]; then
                fileExtension="${submission2##*.}"
                if [[ " ${programmingLanguages[@]} " =~ " ${fileExtension} " ]]; then

                    fileNameWithExtension=${submission2##*/}
                    fileName=$studentID2

                    flag=1
                    outputPath="./home/unarchivedAssignment/$studentID/$studentID/${fileName}_outout.txt"
                    touch $outputPath
                    compileAndRun $fileExtension "./home/unarchivedAssignment/$studentID/$studentID/$fileNameWithExtension" "./home/unarchivedAssignment/$studentID/$studentID/$fileName" $outputPath
                        
                    resultTem=$(checkOutput $outputPath)

                    marksForEveryStudent["$studentID"]=$((marksForEveryStudent["$studentID"] - $resultTem))
                fi
            fi
        done

        if [ "$flag" -eq 0 ]; then
            remarks["$studentID"]="${remarks["$studentID"]} issue case #3"
            mv "$submission" "./issues"
        else
            mv "$submission" "./checked"
        fi 

    done
done



# final calculation
csv_file="./home/assignment/marks.csv"

touch "./home/assignment/marks.csv"

plagiarism_ids=()
while IFS= read -r line; do
    trimmedLine=$(trim "$line")
    plagiarism_ids+=("$trimmedLine")
done < "$plagiarismFilePath"

for (( student="${studentIdRange[0]}"; student<="${studentIdRange[1]}"; student++ ))
do

    studentID=$student
    if [[ " ${present_students[@]} " =~ " ${studentID} " ]]; then
        if [[ " ${plagiarism_ids[@]} " =~ " ${studentID} " ]]; then
            col1="$student"
            col3=$(( ${marksForEveryStudent[$student]} - $totalMarks ))
            marksForEveryStudent[$student]=$((marksForEveryStudent[$student] + $totalMarks))
            col2=${marksForEveryStudent[$student]}
            col3=$(( 0 - $col3 )) 
            col4="$totalMarks"
            remarks[$student]="${remarks[$student]} plagiarism detected"
            col5="${remarks[$student]}"
            echo "$col1,$col2,$col3,$col4,$col5" >> "$csv_file"
        else
            col1="$student"
            col3=$(( ${marksForEveryStudent[$student]} - 0 ))
            marksForEveryStudent[$student]=$((marksForEveryStudent[$student] + $totalMarks))
            col2=${marksForEveryStudent[$student]}
            col3=$(( 0 - $col3 ))  

            col4="$totalMarks"
            col5="${remarks[$student]}"
            echo "$col1,$col2,$col3,$col4,$col5" >> "$csv_file"
        fi
    else
        col1="$student"
            col3=0
            col2=0
            col3=0

            col4="$totalMarks"
            col5="${remarks[$student]}"
            echo "$col1,$col2,$col3,$col4,$col5" >> "$csv_file"
    fi
done
