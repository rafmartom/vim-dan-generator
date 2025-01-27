/**
 * This utility script takes an input string as an argument, detects its programming language,
 * and prints the detected language based on the provided list of available languages.
 *
 * Usage:
 *   node scripts/getSyntaxExtension.js "<code-snippet>"
 *
 * Example:
 *   node scripts/getSyntaxExtension.js "def hello(): print('Hello, World!')"
 *
 * Notes:
 * - The `languagesAvailable` array specifies which languages to consider during detection.
 * - Certain languages can be commented out temporarily to avoid conflicts during detection.
 */

// Check if an argument is provided
if (process.argv.length < 3) {
    console.error("Error: Please provide a code snippet as an argument.");
    console.error("Usage: node scripts/getSyntaxExtension.js \"<code-snippet>\"");
    process.exit(1);
}

// Capture the input string from the command-line argument
const inputString = process.argv[2];

// Second argument correspond to defaultSyntax
const defaultLang = process.argv[3];


/* 
// METHOD 1 via highlight.js
const hljs = require('highlight.js');

// Perform language detection
const outputLang = hljs.highlightAuto(inputString, languagesAvailable);

// Output the detected language
console.log(outputLang.language);


*/


// Define languages to consider for detection
const availableLangs = ['js', 'ts', 'json', 'html', 'xml', 'bash', 'java', 'lua', 'css', 'sql', 'http', 'py', 'vim', 'ps'];


var prompt = "Im sending you a piece of code I need you to identify its syntax, give me out the extension of the syntax (without the dot) such as js, json, html, lua, vim, ps... If you are not sure about the syntax respond undefined. Dont look further than the following extensions" + availableLangs.join() + " . If your guessed syntax its outside the previous list, return undefined." ;

prompt += inputString;

//prompt = "Please find after this a piece of code I need you to identify the language is coming from. Reply me with just the extension of the files of the corresponding progamming language i.e. js, json, html, lua, vim, ps ... If you are not really sure just respond undefined"

// METHOD 2 via AI GOOGLE GEMINI 1.5

const { GoogleGenerativeAI } = require("@google/generative-ai");
require('dotenv').config();

const genAI = new GoogleGenerativeAI(process.env.GOOGLE_AI_API_KEY);


async function promptAiText (prompt) {
const model = genAI.getGenerativeModel({ model: "gemini-1.5-flash"});

    const result = await model.generateContent(prompt);
    const response = await result.response;
    return response.text();
}

async function main () {
    var outputLang; 

    try {
        // Attempt to get the language from the AI
        outputLang = await promptAiText(prompt);
    } catch (error) {
        // Handle errors gracefully
        if (error.status === 503) { // Service Unavailable
            console.error("Service unavailable. Returning 'undefined'.");
        } else {
            console.error("An unexpected error occurred:", error);
        }
        outputLang = 'undefined';
    }

console.error(`defaultLang : ${defaultLang}`) // DEBUGGING

    if (outputLang == 'undefined') {
        outputLang = defaultLang;
    // Check if the outputLang doesnt match any of the availableLangs if not return defaultLang
    } else if ( availableLangs.some( (language) => outputLang == language ? false : true) ) {
        outputLang = defaultLang;
    } 
console.error(`outputLang : ${outputLang}`)// DEBUGGING

    console.log(outputLang);
}

main();
