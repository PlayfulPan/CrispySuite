import os
import sys
import subprocess
from win32com.client.dynamic import Dispatch

#==============================================================
#==================== Execution Options =======================

mainFile = 'TestDocument' # The main .tex file without file extension
pdfName = 'TestDocument' # The desired PDF file name without extension

use_TeXEngine = 1 # PDFLaTeX = 0 | LuaLaTeX = 1 | XeLaTeX = 2
use_BibEngine = 2 # No Bibliography = 0 | BibTeX = 1 | Biber = 2 

#--------------------------------------------------------------

clean_Before = True # Clear auxillary files + specified files before compilling
clean_After = True # Clearauxillary files + specified files after compilling

protectedExtensions = ['.py', '.bib', '.tex'] # Protect file extensions
protectedFiles = [] # Protect certain files from being cleaned | Must contain extension

clearExtensions = [] # Extensions to remove | Overridden by protected exentions
clearFiles = [] # Files to remove w/ extensions | Overrides protected extensions, but not protected files

#--------------------------------------------------------------

useAuxDirectory = True	# Whether to use an auxillary directory
auxDirectoryName = 'auxillary' #Name of auxillary folder to be created in current working directory

pdfInteraction = True # Close/Open PDF file

maxRunCount = 5 # Maximum number of times to rerun LaTeX

#=============================================================
#================== Script Configuration =====================

texEngines = [
				'pdflatex',
				'lualatex',
				'xelatex'
			]

auxFileExtensions = [
						'.aux',
						'.bbl',
						'.out',
						'.loe',
						'.run.xml',
						'.bcf',
						'.blg',
						'.log'
					]

tex_ReRun_Messages = [
						'LaTeX Warning: Label(s) may have changed. Rerun to get cross-references right.',
						'and rerun LaTeX afterwards.',
						'Package biblatex Warning: Please rerun LaTeX',
						'(rerunfilecheck)                Rerun to get outlines right',
						'Package bibunits Warning: Label(s) may have changed. Rerun to get cross-referen'
					]

biber_ReRun_Messages = [
						'Package biblatex Warning: Please (re)run Biber on the file'
					]

#================================================================
#======================= Initialization =========================

workingDirectory = os.getcwd()
auxDirectory = workingDirectory
if useAuxDirectory:
	auxDirectory = workingDirectory+'\\'+auxDirectoryName

#================================================================
#========================== Modules =============================

def runLaTeX(**kwargs):
	texCommands = []

	texEngine = kwargs.get('texEngine', texEngines[use_TeXEngine])
	texCommands.append(texEngine)

	interactionMode = kwargs.get('interactionMode', 'nonstopmode')
	texCommands.append('-interaction='+interactionMode)

	auxFileDirectory = kwargs.get('auxFileDirectory', auxDirectory)
	texCommands.append('-aux-directory='+auxFileDirectory)
	
	fileName = kwargs.get('fileName', mainFile)
	texCommands.append(fileName)
	
	subprocess.run(texCommands)

#-------------------------------------------------------------------

def runBibTeX(**kwargs):
	bibtexCommands = ['bibtex']

	callPath = kwargs.get('callPath', auxDirectory)
	
	includeDirectories = kwargs.get('includeDirectories', [workingDirectory])
	for path in includeDirectories:
		bibtexCommands.append('-include-directory='+path)

	detectAll = kwargs.get('detectAll', True)
	if detectAll:
		fileNames = []
		filelist = os.listdir(callPath)
		
		for name in filelist:
			if name.endswith('.aux'):
				fileNames.append(name.replace('.aux',''))
	else:
		fileNames = kwargs.get('fileNames', [mainFile])

	for file in fileNames:
		subprocess.run(bibtexCommands+[file], cwd=callPath)


#---------------------------------------------------------------------------------

def runBiber(**kwargs):
	biberCommands = ['biber']

	auxFileDirectory = kwargs.get('auxFileDirectory', auxDirectory)
	biberCommands.append('--output-directory')
	biberCommands.append(auxFileDirectory)

	fileName = kwargs.get('fileName', mainFile)
	biberCommands.append(fileName)

	subprocess.run(biberCommands)

#---------------------------------------------------------------------------------

def getLaTeXRequests(**kwargs):
	fileLocation = kwargs.get('fileLocation', auxDirectory)
	fileName = kwargs.get('fileName', mainFile+".log")

	print("\nChecking for LaTeX run requests...")
	rerun_TeX = False

	logFile = open(fileLocation+'\\'+fileName, "r", encoding="utf8")
	for line in logFile:
		for message in tex_ReRun_Messages:
			if message in line:
				rerun_TeX = True
				print('\nDetected LaTeX run message: "'+message+'"')

	if not rerun_TeX:
		print("\nNo LaTeX run requests!")
	
	return rerun_TeX

def getBiberRequests(**kwargs):
	fileLocation = kwargs.get('fileLocation', auxDirectory)
	fileName = kwargs.get('fileName', mainFile+".log")

	print("\nChecking for Biber run requests...")

	rerun_Biber = False

	logFile = open(fileLocation+'\\'+fileName, "r", encoding="utf8")
	for line in logFile:
		for message in biber_ReRun_Messages:
			if message in line:
				rerun_Biber = True
				print('\nDetected Biber run message: "'+message+'"')

	if not rerun_Biber:
		print("\nNo Biber run requests!")
	
	return rerun_Biber



#---------------------------------------------------------------------------------

def cleanUp(**kwargs):
	directories = kwargs.get('directories', [auxDirectory])

	removeExtensions = kwargs.get('delExtensions', auxFileExtensions+clearExtensions)
	removeFiles = kwargs.get('delFiles', clearFiles)

	keepExtensions = kwargs.get('keepExtensions', protectedExtensions)
	keepFiles = kwargs.get('keepFiles', protectedFiles)

	for path in directories:
		if os.path.exists(path):	
			fileList = os.listdir(path)
			preRemoveList = []

			for file in fileList:
				addToRemoveList = False
				for extension in removeExtensions:
					if file.endswith(extension):
						addToRemoveList=True
				if addToRemoveList:
					preRemoveList.append(file)

			removeList = []
			for file in preRemoveList:
				addToRemoveList = True

				for extension in keepExtensions:
					if file.endswith(extension):
						addToRemoveList = False

				if addToRemoveList:
					removeList.append(file)

			removeList = removeList + removeFiles

			for file in keepFiles:
				while (file in removeList):
					removeList.remove(file)

			for file in removeList:
				fullName = path+'\\'+file

				if os.path.exists(fullName):
					os.remove(fullName)
					print("Removed file: "+"'"+fullName+"'")
				else:
					print("Removal Failed: ""'"+fullName+"' does not exist!")
		else:
			print("Can't find path: "+path)

#---------------------------------------------------------------------------------

def closePDFS():
	Acrobat = Dispatch("AcroExch.App")
	Acrobat.CloseAllDocs()
	Acrobat.Exit()

def openPDF(**kwargs):
	fileLocation = kwargs.get('fileLocation', workingDirectory)
	fileName = kwargs.get('fileName', pdfName+'.pdf')
	subprocess.Popen([fileName], cwd=fileLocation, shell=True)

def renamePDF(**kwargs):
	directory = kwargs.get('directory', workingDirectory)
	beforeName = kwargs.get('beforeName', mainFile+'.pdf')
	afterName = kwargs.get('afterName', pdfName+'.pdf')

	if beforeName == afterName:
		return

	fullBeforeName = directory+'\\'+beforeName
	fullAfterName = directory+'\\'+afterName

	if not os.path.exists(fullBeforeName):
		print("Can't rename! '"+fullBeforeName+"' does not exist!")
		return

	if os.path.exists(fullAfterName):
  		os.remove(fullAfterName)

	os.rename(fullBeforeName, fullAfterName)

#===================================================
#================ Compile Script ===================

#------------------ Pre-Compile --------------------

if pdfInteraction:
	closePDFS()

if clean_Before:
	cleanUp()

# ------------------ Compile -----------------------

run_TeX = True
run_BibTeX = False
run_Biber = False

tex_RunCount = 0

if use_BibEngine == 1:
	run_BibTeX = True

while run_TeX and tex_RunCount< maxRunCount:
	if tex_RunCount > 0:
		if run_BibTeX:
			runBibTeX()
			run_BibTeX = False
		
		if run_Biber:
			runBiber()
			run_Biber=False

	runLaTeX()
	tex_RunCount = tex_RunCount+1
	run_TeX = False
	
	if use_BibEngine == 2:
		run_Biber = getBiberRequests()
		run_TeX = run_Biber
		if not run_Biber:
			run_TeX = getLaTeXRequests()
	else:
		if run_BibTeX:
			run_TeX = True
		else:
			run_TeX = getLaTeXRequests()

# ------------------ Post Compile ------------------

renamePDF()

if clean_After:
	cleanUp()

if pdfInteraction:
	openPDF()