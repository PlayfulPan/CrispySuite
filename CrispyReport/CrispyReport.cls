\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{CrispyReport}

\RequirePackage{etoolbox}
\RequirePackage{iftex}

\newbool{@PDFBannerBool}
\newbool{@PDFDateInfoBool}

\DeclareOption{showPDFBanner}{\booltrue{@PDFBannerBool}}% These options control the PDF.TeX banner and date metadata of the PDF
\DeclareOption{supressPDFDateInfo}{\booltrue{@PDFDateInfoBool}}

\DeclareOption*{\PassOptionsToClass{\CurrentOption}{revtex4-2}}
\ProcessOptions\relax
\LoadClass[noamsfonts,noamssymb,noamsmath]{revtex4-2}

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
    %\RequirePackage{amsthm,thmtools}
    \RequirePackage{graphicx}
    \RequirePackage{pgf}
    \RequirePackage{enumitem}
    \RequirePackage[bookmarks=false]{hyperref}
    \RequirePackage{cleveref}

    % Hyperlink Format
            \hypersetup{
                %pdftitle={},
                %pdfauthor={},
                %pdfsubject={},
                %pdfkeywords={},
                %pdfcreator={},
                %pdfproducer={},
                pdftrapped=False,
                pdflang={en-US},%
                %
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

        \newcommand{\subcref}[2][]{\ifblank{#1}{\labelcref{#2}}{\cref{#1}\labelcref{#2}}} % This gives the reference to a "mini" item, the optional argument is the label for the parent item
        \newcommand{\subCref}[2][]{\ifblank{#1}{\labelcref{#2}}{\Cref{#1}\labelcref{#2}}}
        \newcommand{\keyterm}[1]{\textbf{\emph{#1}}}
