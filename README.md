# LNNDG
This small project provide a script to quickly generate a database to train an OCR.

> ⚠️ **Warning**: The databases generated can be very large and take up a lot of space depending on the options chosen.

## Why?
Sometimes I just want to focus on the code and avoid all external actions that take time but are not directly related to the code. I was implementing an OCR and I needed a way to deploy a training database on all the machines I would have to work on without having to download and remodel it every time. So I created this script which allows me to generate a small database from the files already present on the computer.

## Limitations
This tool is designed to be used in a test phase more than for final training. The database is generated from local font files, so using it can lead to a lack of variety in training examples.

## Dependencies
This project requires ImageMagick and at least one font file to work properly.
