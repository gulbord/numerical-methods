\NeedsTeXFormat{LaTeX2e}[2020/10/01]
\ProvidesClass{gulartcl}[2021/05/30 v1.0 LaTeX document class]
\newcommand\@ptsize{}
\newif\if@restonecol
\newif\if@titlepage
\@titlepagefalse

\setlength\paperheight{297mm}
\setlength\paperwidth{210mm}
\DeclareOption{10pt}{\renewcommand\@ptsize{0}}
\DeclareOption{11pt}{\renewcommand\@ptsize{1}}

\DeclareOption{openbib}{%
	\AtEndOfPackage{%
		\renewcommand\@openbib@code{%
			\advance\leftmargin\bibindent
			\itemindent -\bibindent
			\listparindent \itemindent
			\parsep \z@
		}%
		\renewcommand\newblock{\par}}%
}
\DeclareOption{twocolumn}{\@twocolumntrue}
\DeclareOption{twoside}{\@twosidetrue \@mparswitchtrue}
\DeclareOption{oneside}{\@twosidefalse \@mparswitchfalse}
\DeclareOption{titlepage}{\@titlepagetrue}
\ExecuteOptions{11pt,oneside}
\ProcessOptions
\input{gul1\@ptsize.clo}

\setlength\lineskip{\z@}
\setlength\normallineskip{\z@}
\lineskiplimit=\z@
\renewcommand\baselinestretch{}
\setlength\parskip{\z@}
\@lowpenalty   51
\@medpenalty  151
\@highpenalty 301
\setcounter{topnumber}{2}
\renewcommand\topfraction{.7}
\setcounter{bottomnumber}{1}
\renewcommand\bottomfraction{.3}
\setcounter{totalnumber}{3}
\renewcommand\textfraction{.2}
\renewcommand\floatpagefraction{.5}
\setcounter{dbltopnumber}{2}
\renewcommand\dbltopfraction{.7}
\renewcommand\dblfloatpagefraction{.5}

\if@twoside
    \def\ps@headings{%
    	\let\@oddfoot\@empty\let\@evenfoot\@empty
    	\def\@evenhead{\thepage\hfil\itshape\leftmark}%
    	\def\@oddhead{{\itshape\rightmark}\hfil\thepage}%
    	\let\@mkboth\markboth
    	\def\sectionmark##1{%
            \markboth{%
                \ifnum \c@secnumdepth >\z@
                    \thesection\enskip
                \fi
                ##1}{%
                \ifnum \c@secnumdepth >\z@
                    \thesection\enskip
                \fi
                ##1}}%
    	\def\subsectionmark##1{%
            \markright{%
                \ifnum \c@secnumdepth >\@ne
                    \thesubsection\enskip
                \fi
                ##1}}}
\else
    \def\ps@headings{%
        \let\@cfoot\thepage
        \def\@oddhead{\itshape\rightmark}%
        \let\@mkboth\markboth
        \def\sectionmark##1{%
            \markright{%
                \ifnum \c@secnumdepth >\m@ne
                    \thesection\enskip
                \fi
                ##1}}}
\fi
\def\ps@myheadings{%
    \let\@oddfoot\@empty\let\@evenfoot\@empty
    \def\@evenhead{\thepage\hfil\itshape\leftmark}%
    \def\@oddhead{{\itshape\rightmark}\hfil\thepage}%
    \let\@mkboth\@gobbletwo
    \let\sectionmark\@gobble
    \let\subsectionmark\@gobble}

\def\ps@plain{%
    \let\@mkboth\@gobbletwo
    \renewcommand{\@oddhead}{}
    \renewcommand{\@oddhead}{}%
    \renewcommand{\@evenhead}{}%
    \renewcommand{\@evenfoot}{%
        \reset@font\hfil\thepage\hfil}%
    \renewcommand{\@oddfoot}{\@evenfoot}}

% get parindent as in normal text
\newlength\normalparindent
\setlength\normalparindent{\the\dimexpr 1.2em\relax}

\if@titlepage
    \newcommand\maketitle{%
        \begin{titlepage}%
            \let\footnotesize\small
            \let\footnoterule\relax
            \let\footnote\thanks
            \null
            \vskip 2\baselineskip%
            \begin{center}
                \let\footnote\thanks
                {\LARGE{\bfseries\@title}\par}%
                \vskip 1\baselineskip%
                {\large\lineskip 5\p@%
                 \begin{tabular}[t]{c}%
                     \@author
                 \end{tabular}\par}%
                 \vskip 1\baselineskip%
                {\large\@date\par}%
            \end{center}\par
            \@thanks
        \end{titlepage}%
        \setcounter{footnote}{0}%
        \global\let\thanks\relax
        \global\let\maketitle\relax
        \global\let\@thanks\@empty
        \global\let\@author\@empty
        \global\let\@date\@empty
        \global\let\@title\@empty
        \global\let\title\relax
        \global\let\author\relax
        \global\let\date\relax
        \global\let\and\relax}
\else
    \newcommand\maketitle{\par
        \begingroup
            \renewcommand\thefootnote{\@fnsymbol\c@footnote}%
            \def\@makefnmark{%
                \rlap{\@textsuperscript{\normalfont\@thefnmark}}}%
            \long\def\@makefntext##1{\hangindent\normalparindent\noindent
                \hb@xt@\normalparindent{\normalfont\@thefnmark.\hss}##1}%
            \if@twocolumn
                \ifnum\col@number=\@ne
                    \@maketitle
                \else
                    \twocolumn[\@maketitle]%
                \fi
            \else
                \newpage
                \global\@topnum\z@
                \@maketitle
            \fi
            \thispagestyle{empty}\@thanks
        \endgroup
        \setcounter{footnote}{0}%
        \global\let\thanks\relax
        \global\let\maketitle\relax
        \global\let\@maketitle\relax
        \global\let\@thanks\@empty
        \global\let\@author\@empty
        \global\let\@date\@empty
        \global\let\@title\@empty
        \global\let\title\relax
        \global\let\author\relax
        \global\let\date\relax
        \global\let\and\relax}
\fi
%\def\@maketitle{%
%	\newpage
%	\null
%	\vskip 2\baselineskip%
%	\begin{center}%
%		\let\footnote\thanks
%		{\LARGE{\bfseries\@title}\par}%
%		\vskip 1\baselineskip%
%    		{\large
%    		\lineskip 5\p@%
%		\begin{tabular}[t]{c}%
%			\@author
%		\end{tabular}\par}%
%		\vskip 1\baselineskip%
%		{\large\@date}%
%	\end{center}%
%	\par
%	\vskip 1\baselineskip plus 4pt minus 4pt}

\def\@maketitle{%
    \newpage
    \null
    \vskip -\topskip
    \vskip 2\baselineskip
    \parindent=0pt
    \let\footnote\thanks
    {\centering\Large{\bfseries\@title}\par}%
    \vskip 0.5\baselineskip%
    {\centering\ifnum\@ptsize=0\large\else\medium\fi\@author\par}
    \vskip 0.5\baselineskip
    {\centering\ifnum\@ptsize=0\large\else\medium\fi\@date\par}
    \vskip 5\baselineskip plus 4pt minus 4pt}

\setcounter{secnumdepth}{3}
\newcounter{section}
\newcounter{subsection}[section]
\renewcommand\thesection{\@arabic\c@section}
\renewcommand\thesubsection{\thesection.\@arabic\c@subsection}
\renewcommand{\@seccntformat}[1]{\csname the#1\endcsname\enskip}

\ifnum\@ptsize=0
\newcommand\section{\@startsection{section}{1}{\z@}%
	{-16\p@ \@plus -4\p@ \@minus -2\p@}%
	{8\p@ \@plus 2\p@}%
	{\large\bfseries}}
\newcommand\subsection{\@startsection{subsection}{2}{\z@}%
	{-8\p@ \@plus -2\p@ \@minus -2\p@}%
	{4\p@ \@plus 2\p@}%
	{\bfseries}}
\else
\newcommand\section{\@startsection{section}{1}{\z@}%
	{-18\p@ \@plus -4\p@ \@minus -4\p@}%
	{10\p@ \@plus 4\p@ \@minus 3\p@}%
	{\medium\bfseries}}
\newcommand\subsection{\@startsection{subsection}{2}{\z@}%
	{-9\p@ \@plus -3\p@ \@minus -3\p@}%
	{5\p@ \@plus 2\p@}%
	{\bfseries}}
\fi

\setlength\leftmargini{2.4em}
\leftmargin\leftmargini
\setlength\leftmarginii{2em}
\setlength\leftmarginiii{1.6em}
\setlength\leftmarginiv{1.2em}
\setlength\leftmarginv{0.8em}
\setlength\leftmarginvi{0.8em}

\setlength\labelsep{.5em}
\setlength\labelwidth{\leftmargini}
\addtolength\labelwidth{-\labelsep}
\@beginparpenalty-\@lowpenalty
\@endparpenalty-\@lowpenalty
\@itempenalty-\@lowpenalty
\renewcommand\theenumi{\@arabic\c@enumi}
\renewcommand\theenumii{\@alph\c@enumii}
\renewcommand\theenumiii{\@roman\c@enumiii}
\renewcommand\theenumiv{\@Alph\c@enumiv}
\newcommand\labelenumi{\theenumi.}
\newcommand\labelenumii{(\theenumii)}
\newcommand\labelenumiii{\theenumiii.}
\newcommand\labelenumiv{\theenumiv.}
\renewcommand\p@enumii{\theenumi}
\renewcommand\p@enumiii{\theenumi(\theenumii)}
\renewcommand\p@enumiv{\p@enumiii\theenumiii}
\newcommand\labelitemi{\labelitemfont\textbullet}
\newcommand\labelitemii{\labelitemfont\bfseries\textendash}
\newcommand\labelitemiii{\labelitemfont\textasteriskcentered}
\newcommand\labelitemiv{\labelitemfont\textperiodcentered}
\newcommand\labelitemfont{\normalfont}
\newenvironment{description}
               {\list{}{\labelwidth\z@ \itemindent-\leftmargin
                        \let\makelabel\descriptionlabel}}
               {\endlist}
\newcommand*\descriptionlabel[1]{\hspace\labelsep\normalfont\bfseries #1}

\newenvironment{abstract}{%
	\if@twocolumn
		\section*{\abstractname}%
	\else
		\small
		\begin{center}%
			{\bfseries\abstractname\vspace{-.5em}\vspace{\z@}}%
        	\end{center}%
		\quotation
	\fi}
	{\if@twocolumn\else\endquotation\fi}
\newenvironment{verse}
               {\let\\\@centercr
                \list{}{\itemsep\z@
                        \itemindent -1.2em%
                        \listparindent\itemindent
                        \rightmargin\leftmargin
                        \advance\leftmargin 1.2em}%
                \item\relax}
               {\endlist}
\newenvironment{quotation}
               {\list{}{\listparindent 1.2em%
                        \itemindent\listparindent
                        \rightmargin\leftmargin
                        \parsep\z@}%
                \item\relax}
               {\endlist}
\newenvironment{quote}
               {\list{}{\rightmargin\leftmargin}%
                \item\relax}
               {\endlist}
\newenvironment{titlepage}
    {%
        \if@twocolumn
            \@restonecoltrue\onecolumn
        \else
            \@restonecolfalse\newpage
        \fi
        \thispagestyle{empty}%
        \setcounter{page}\@ne
    }{%
        \if@restonecol
            \twocolumn
        \else
            \newpage
        \fi
        \if@twoside
        \else
            \setcounter{page}\@ne
        \fi
    }
\newcommand\appendix{\par
	\setcounter{section}{0}%
	\setcounter{subsection}{0}%
	\gdef\thesection{\@Alph\c@section}}
\setlength\arraycolsep{5\p@}
\setlength\tabcolsep{6\p@}
\setlength\arrayrulewidth{.4\p@}
\setlength\doublerulesep{2\p@}
\setlength\tabbingsep{\labelsep}
\skip\@mpfootins=\skip\footins
\setlength\fboxsep{3\p@}
\setlength\fboxrule{.4\p@}
\@addtoreset{equation}{section}
\renewcommand\theequation{
    \ifnum \c@section >\z@ \thesection.\fi \@arabic\c@equation}
\newcounter{figure}
\renewcommand\thefigure{\@arabic\c@figure}
\def\fps@figure{tbp}
\def\ftype@figure{1}
\def\ext@figure{lof}
\def\fnum@figure{\figurename\nobreakspace\thefigure}
\newenvironment{figure}
	{\edef\@tempa{\noexpand\@float{figure}[\fps@figure]}
     \@tempa
     \small}
	{\end@float}
\newenvironment{figure*}
	{\edef\@tempa{\noexpand\@dblfloat{figure}[\fps@figure]}
     \@tempa
     \small}
	{\end@dblfloat}
\newcounter{table}
\renewcommand\thetable{%
    \ifnum \c@section >\z@ \thesection.\fi \@arabic\c@table}
\def\fps@table{tbp}
\def\ftype@table{2}
\def\ext@table{lot}
\def\fnum@table{\tablename\nobreakspace\thetable}
\newenvironment{table}
	{\edef\@tempa{\noexpand\@float{table}[\fps@figure]}
     \@tempa
     \small}
	{\end@float}
\newenvironment{table*}
	{\edef\@tempa{\noexpand\@dblfloat{table}[\fps@figure]}
     \@tempa
     \small}
	{\end@dblfloat}

\newlength\abovecaptionskip
\newlength\belowcaptionskip
\RequirePackage{booktabs}
\ifnum\@ptsize=0
\setlength\abovecaptionskip{8\p@ \@plus 2\p@ \@minus 2\p@}
\setlength\abovetopsep{3\p@}
\else
\setlength\abovecaptionskip{9\p@ \@plus 3\p@ \@minus 3\p@}
\setlength\abovetopsep{3\p@}
\fi
\setlength\belowcaptionskip{0\p@}

\long\def\@makecaption#1#2{%
	\vskip\abovecaptionskip
	\sbox\@tempboxa{\small{\bfseries #1:} #2}%
	\ifdim\wd\@tempboxa>\hsize
	{\small{\bfseries #1:} #2\par}
	\else
	\global\@minipagefalse
	\hb@xt@\hsize{\hfil\box\@tempboxa\hfil}%
	\fi
	\vskip\belowcaptionskip}

\DeclareOldFontCommand{\rm}{\normalfont\rmfamily}{\mathrm}
\DeclareOldFontCommand{\sf}{\normalfont\sffamily}{\mathsf}
\DeclareOldFontCommand{\tt}{\normalfont\ttfamily}{\mathtt}
\DeclareOldFontCommand{\bf}{\normalfont\bfseries}{\mathbf}
\DeclareOldFontCommand{\it}{\normalfont\itshape}{\mathit}
\DeclareOldFontCommand{\sl}{\normalfont\slshape}{\@nomath\sl}
\DeclareOldFontCommand{\sc}{\normalfont\scshape}{\@nomath\sc}
\DeclareRobustCommand*\cal{\@fontswitch\relax\mathcal}
\DeclareRobustCommand*\mit{\@fontswitch\relax\mathnormal}
\newcommand\@pnumwidth{1.2em}
\newcommand\@tocrmarg{2.4em}
\newcommand\@dotsep{4.5}
\setcounter{tocdepth}{3}
\newcommand\tableofcontents{%
	\section*{\contentsname}\@mkboth{\contentsname}{\contentsname}%
	\@starttoc{toc}%
}

\newcommand*\l@section[2]{%
	\ifnum \c@tocdepth >\z@
		\addpenalty\@secpenalty
		\setlength\@tempdima{1.2em}%
		\begingroup
			\parindent\z@ \rightskip\@pnumwidth
            \parfillskip -\@pnumwidth
			\leavevmode
			\advance\leftskip\@tempdima
			\hskip -\leftskip
			\bfseries #1
            \nobreak\hb@xt@\@pnumwidth{\hss #2%
                                       \kern-\p@\kern\p@}\par
            \penalty\@highpenalty
		\endgroup
	\fi}

\newcommand*\l@subsection{\@dottedtocline{1}{1.2em}{1.7em}}

\newdimen\bibindent
\setlength\bibindent{1.2em}
\newenvironment{thebibliography}[1]
	{\section*{\refname}%
	\@mkboth{\refname}{\refname}%
	\list{\@biblabel{\@arabic\c@enumiv}}%
		{\settowidth\labelwidth{\@biblabel{#1}}%
		\leftmargin\labelwidth
		\advance\leftmargin\labelsep
		\@openbib@code
		\usecounter{enumiv}%
		\let\p@enumiv\@empty
		\renewcommand\theenumiv{\@arabic\c@enumiv}}%
		\sloppy
		\clubpenalty4000
		\@clubpenalty \clubpenalty
		\widowpenalty4000%
		\sfcode`\.\@m}
		{\def\@noitemerr{\@latex@warning{Empty `thebibliography' environment}}%
	\endlist}
\newcommand\newblock{\hskip .11em\@plus.33em\@minus.07em}
\let\@openbib@code\@empty
\newenvironment{theindex}
	{\if@twocolumn
		\@restonecolfalse
	\else
		\@restonecoltrue
	\fi
	\twocolumn[\section*{\indexname}]\@mkboth{\indexname}{\indexname}%
	\thispagestyle{empty}\parindent\z@
	\parskip \z@\relax
	\columnseprule\z@
    \ifnum\@ptsize=0
        \columnsep=18\p@
    \else
	    \columnsep 21\p@
    \fi
	\let\item\@idxitem}{\if@restonecol\onecolumn\else\clearpage\fi}
\newcommand\@idxitem{\par\hangindent 2.4em}
\newcommand\subitem{\@idxitem \hspace*{1.2em}}
\newcommand\subsubitem{\@idxitem \hspace*{1.8em}}
\newcommand\indexspace{\par\vskip\medskipamount}
\renewcommand\footnoterule{%
	\kern-3\p@
	\hrule\@width.4\columnwidth
	\kern2.6\p@}
\newcommand\@makefntext[1]{%
	\hangindent\normalparindent\noindent
	\hb@xt@\normalparindent{\normalfont\@thefnmark.\hss}#1}
\newcommand\contentsname{Contents}
\newcommand\listfigurename{List of Figures}
\newcommand\listtablename{List of Tables}
\newcommand\refname{References}
\newcommand\indexname{Index}
\newcommand\figurename{Figure}
\newcommand\tablename{Table}
\newcommand\partname{Part}
\newcommand\appendixname{Appendix}
\newcommand\abstractname{Abstract}
\def\today{\ifcase\month\or
  January\or February\or March\or April\or May\or June\or
  July\or August\or September\or October\or November\or December\fi
  \space\number\day, \number\year}
\ifnum\@ptsize=0
    \setlength\columnsep{18\p@}
\else
    \setlength\columnsep{21\p@}
\fi
\setlength\columnseprule{0\p@}
\pagestyle{plain}
\pagenumbering{arabic}

%\if@twoside
%\else
%    \raggedbottom
%\fi
\if@twocolumn
    \twocolumn
    \flushbottom
\else
    \onecolumn
\fi

\endinput
%%
%% End of file `gulartcl.cls'.
