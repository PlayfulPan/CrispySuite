\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{CrispyNotes}

\RequirePackage{etoolbox}
\RequirePackage{iftex}

\newbool{@PDFBannerBool}
\newbool{@PDFDateInfoBool}
\newbool{@TheoremNumBool}

\DeclareOption{showPDFBanner}{\booltrue{@PDFBannerBool}}% These options control the PDF.TeX banner and date metadata of the PDF
\DeclareOption{supressPDFDateInfo}{\booltrue{@PDFDateInfoBool}}
\DeclareOption{ThmSectionNumbering}{\booltrue{@TheoremNumBool}}

\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
\ProcessOptions\relax
\LoadClass{article}

\ifbool{@PDFBannerBool}{}{
        \ifLuaTeX
             \pdfvariable suppressoptionalinfo \numexpr
                 0
             +   1   % PTEX.FullBanner
             +   2   % PTEX.FileName
             +   4   % PTEX.PageNumber
             +   8   % PTEX.InfoDict
            \relax

        \else
            \pdfsuppressptexinfo -1
        \fi
    }

\ifbool{@PDFDateInfoBool}{
        \ifLuaTeX
             \pdfvariable suppressoptionalinfo \numexpr
                 0
             +  32   % CreationDate
             +  64   % ModDate
            \relax

        \else
            \pdfinfoomitdate -1
        \fi
    }{}



% Packages %

    \RequirePackage[margin=1in]{geometry}
    \RequirePackage{CrispyType}
    \RequirePackage{amsthm,thmtools}
    \RequirePackage{enumitem}
    \RequirePackage[style=CrispyBib]{biblatex}
    \RequirePackage[a-3u]{pdfx}
    \RequirePackage{cleveref}




    % Hyperlink Format
            \hypersetup{
                pdfstartview=Fit,
                pdfremotestartview=Fit,
                pdfstartpage=1,
                pdfview={XYZ null null null},
                pdfpagelayout=SinglePage,%
                %
                pdfdisplaydoctitle=True,
                pdftoolbar=True,
                pdfmenubar=True,
                pdfpagemode=UseNone,%
                %
                colorlinks = true,
                linkcolor=blue,
                citecolor=blue,
                urlcolor=blue,%
        }

        % Cleveref format for equations and default labels
        \crefdefaultlabelformat{#2{\upshape #1}#3}
        \crefformat{equation}{Equation~\upshape(#2{#1}#3)}
        \Crefformat{equation}{Equation~\upshape(#2{#1}#3)}
        \labelcrefformat{equation}{\upshape(#2{#1}#3)}


% Theorem Environments %

%Lengths and technical adjustments

        \patchcmd{\cref@thmoptarg}{\trivlist}{\list{}{\leftmargin=\thm@leftmargin\rightmargin=\thm@rightmargin}}{}{} %These patch the commands for the theorem environments to allow for margin changes (Cleveref redefines the commands, if there wasn't cleveref, the command to patch would be \@thm)
        \patchcmd{\cref@thmnoarg}{\trivlist}{\list{}{\leftmargin=\thm@leftmargin\rightmargin=\thm@rightmargin}}{}{}
        \patchcmd{\@endtheorem}{\endtrivlist}{\endlist}{}{}

        \newlength{\thm@leftmargin}% Default parameters for theorem environments
            \setlength{\thm@leftmargin}{\parindent}
        \newlength{\thm@rightmargin}
            \setlength{\thm@rightmargin}{\parindent}
        \newlength{\thm@parindent}
            \setlength{\thm@parindent}{\parindent}
        \newlength{\thm@parskip}
            \setlength{\thm@parskip}{\parskip}
        \newlength{\thm@postheadspace}
            \setlength{\thm@postheadspace}{1ex}
        \newlength{\thm@spacing}
            \setlength{\thm@spacing}{\topsep}

        \newcommand{\xdeclaretheorem}[4][]{% Declare a theorem with custom margins
            \newenvironment{#4}
            {\thm@leftmargin=#2\relax\thm@rightmargin=#3\relax\begin{#4INNER}}
            {\end{#4INNER}}%
            \declaretheorem[#1]{#4INNER}%
        }


% Theorem Styles

        \declaretheoremstyle[% italic style
            spaceabove=\thm@spacing,
            spacebelow=\thm@spacing,
            notefont=\bfseries,
            postheadspace=\thm@postheadspace,
            bodyfont=\setlength{\parindent}{\thm@parindent}\setlength{\parskip}{\thm@parskip}\itshape,
            ]{italic}

        \declaretheoremstyle[% upright style
            spaceabove=\thm@spacing,
            spacebelow=\thm@spacing,
            notefont=\bfseries,
            postheadspace=\thm@postheadspace,
            bodyfont=\setlength{\parindent}{\thm@parindent}\setlength{\parskip}{\thm@parskip}\upshape
            ]{upright}

        \declaretheoremstyle[% Proof Style
            spaceabove=\thm@spacing,
            spacebelow=\thm@spacing,
            headfont=\mdseries\scshape,
            notefont=\mdseries\scshape,
            notebraces={\mbox{}\mbox{}},
            postheadspace=\thm@postheadspace,
            bodyfont=\setlength{\parindent}{\thm@parindent}\setlength{\parskip}{\thm@parskip}\upshape
            ]{myProof}

        \providecommand{\qedsymbol}{}
        \renewcommand{\qedsymbol}{\raisebox{0.08em}{\ensuremath{\mdwhtsquare}}} %Sets the QED symbol

% Theorem Declarations
        % Theorem Environment


        \ifbool{@TheoremNumBool}{
            \declaretheorem[style=italic, parent=section, numberwithin=section, refname={Theorem, Theorems}]{theorem}
        }{
            \declaretheorem[style=italic, refname={Theorem, Theorems}]{theorem}
        }
            \declaretheorem[style=italic, numbered=no, title=Theorem]{theorem*}

        % Lemma Environment

            \declaretheorem[style=italic, sibling=theorem, numberlike=theorem, refname={Lemma, Lemmas}]{lemma}
            \declaretheorem[style=italic, numbered=no, title=Lemma]{lemma*}

        % Corollary Environment

            \declaretheorem[style=italic, sibling=theorem, numberlike=theorem, refname={Corollary, Corollaries}]{corollary}
            \declaretheorem[style=italic, numbered=no, title=Corollary]{corollary*}

        % Proposition Environment

            \declaretheorem[style=italic, sibling=theorem, numberlike=theorem, refname={Proposition, Propositions}]{proposition}
            \declaretheorem[style=italic, numbered=no, title=Proposition]{proposition*}

        % Definition Environment

            \declaretheorem[style=upright, sibling=theorem, numberlike=theorem, refname={Definition, Definitions}]{definition}
            \declaretheorem[style=upright, numbered=no, title=Definition]{definition*}

        % Remark Environment

            \declaretheorem[style=upright, sibling=theorem, numberlike=theorem, refname={Remark, Remarks}]{remark}
            \declaretheorem[style=upright, numbered=no, title=Remark]{remark*}

        % Example Environment

            \declaretheorem[style=upright, sibling=theorem, numberlike=theorem, refname={Example, Examples}]{example}
            \declaretheorem[style=upright, numbered=no, title=Example]{example*}

        % Proof Environment

            \declaretheorem[style=myProof, numbered=no,prefoothook={\qed}, title=Proof]{myProof}
            \renewenvironment{proof}[1][]{\ifblank{#1}{\begin{myProof}}{\begin{myProof}[#1]}}{\end{myProof}}

        % Problem/Solution Environments

            \xdeclaretheorem[style=italic, title=Problem, refname={Problem, Problems}]{0pt}{0pt}{problem}
            \declaretheorem[style=myProof, numbered=no, prefoothook={\qed}, title=Solution]{solution}

        % Theorem Items
            \newlist{thmitems}{enumerate}{1}
            \setlist[thmitems]{label={\normalfont(\alph*)}, ref={\alph*}}
            \labelcrefformat{thmitemsi}{{\upshape(#2{#1}#3)}}


% Custom Commands

    \newcommand{\subcref}[2][]{\ifblank{#1}{\labelcref{#2}}{\cref{#1}\labelcref{#2}}} % This gives the reference to a "mini" item, the optional argument is the label for the parent item
    \newcommand{\subCref}[2][]{\ifblank{#1}{\labelcref{#2}}{\Cref{#1}\labelcref{#2}}}
    \newcommand{\keyterm}[1]{\textbf{\emph{#1}}}
