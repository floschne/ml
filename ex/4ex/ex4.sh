#!/bin/bash

training_set=$1
test_set=$2

if [[ -z $1 ]]; then
    echo "Provide path to training_set and test_set!"
    exit 1
fi

for i in 0 1 2 3
do
    suffix=""
    case "$i" in
        0) echo "Using linear kernel..."
            suffix=linear;;
        1) echo "Using polynomial kernel..."
            suffix=poly;;
        2) echo "Using RBF kernel..."
            suffix=rbf;;
        3) echo "Using sigmoid kernel..."
            suffix=sigm;;
    esac
    
    mkdir -p "$(pwd)/results/$suffix"

    out="$(pwd)/results/$suffix/$(basename $training_set).${suffix}.out"
    png="$(pwd)/results/$suffix/$(basename $training_set).${suffix}.png"
    model="$(pwd)/results/$suffix/$(basename $training_set).${suffix}.model"
    preds="$(pwd)/results/$suffix/$(basename $training_set).${suffix}.preds"

    echo "Running svm-grid -t $i -png $png -out $out $training_set"
    echo $'\n'
    echo "Best Parameters:"
    echo $'C\tgamma\tCV-rate'
    svm-grid -t $i -png $png -out $out $training_set | tee "$out" | tail -1 | sed $'s/ /\t/' 

    C=$(tail -1 $out | cut -d' ' -f1)
    gamma=$(tail -1 $out | cut -d' ' -f2)


    echo "Running svm-train -t $i -s 0 -g $gamma -c $C $training_set $model"
    echo $'\n'
    svm-train -t $i -s 0 -g $gamma -c $C $training_set $model

    echo "Running svm-predict $test_set $model $preds"
    echo $'\n'
    svm-predict $test_set $model $preds >> $preds

    echo $'\n'
    echo "Grid Search Output: $out"
    echo "Grid Search Graph: $png"
    echo "Model: $model"
    echo "Predictions: $preds"
    echo $'\n\n\n'
done
