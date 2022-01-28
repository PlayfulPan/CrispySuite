\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{CrispyBeamer}

\RequirePackage{etoolbox}
\RequirePackage{iftex}

\newbool{@PDFBannerBool}
\newbool{@PDFDateInfoBool}

\DeclareOption{showPDFBanner}{\booltrue{@PDFBannerBool}}% These options control the PDF.TeX banner and date metadata of the PDF
\DeclareOption{supressPDFDateInfo}{\booltrue{@PDFDateInfoBool}}

\DeclareOption*{\PassOptionsToClass{\CurrentOption}{beamer}}
\ProcessOptions\relax
\LoadClass{beamer}

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

    %\RequirePackage[margin=1in]{geometry}
    \RequirePackage{CrispyType}
    %\RequirePackage{amsthm,thmtools}
    \RequirePackage{graphics}
    \RequirePackage{pgf}
    \RequirePackage{enumitem}
    \RequirePackage[style=CrispyBib]{biblatex}
    \RequirePackage{hyperref}

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

\renewcommand{\bibname}{References}
\newcommand{\keyterm}[1]{\textbf{\emph{#1}}}

\usefonttheme{professionalfonts}
\usefonttheme{serif}

\setbeamercolor{bibliography entry author}{fg=black}
\setbeamercolor{bibliography entry title}{fg=black}
\setbeamercolor{bibliography item}{fg=black}
\setbeamercolor{bibliography entry location}{fg=black}
\setbeamercolor{bibliography entry note}{fg=black}


\setbeamercolor{button}{fg=blue}
