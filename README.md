#   PSCI 8357 (Spring 2025)  
  Statistics for Political Research II

------------------------------------------------------------------------

#### **Instructor:** Georgiy (Gosha) Syunyaev (<g.syunyaev@vanderbilt.edu>)

-   **Office hours:** Wednesday, 2-4 PM or by appointment in Commons 351
-   **Office hourse sign-up link:**
    <https://calendar.app.google/MnsMZr3F6SYaBk7g7>

#### **TA:** Alexander (Alex) Dean

-   **Recitations:** Friday, 2-3 PM in LAPOP
-   **Office hours:** Friday, 3-5 PM or by appointment in Commons 317

------------------------------------------------------------------------

## Course Overview

This course offers an up-to-date exploration of causal inference in
quantitative social science research. We will study two main components
of causal inference: (1) the analysis of causal identification and (2)
statistical inference based on research design. Our focus will be on
non-parametric causal identification methods, along with non-parametric
and semi-parametric estimation techniques. Additionally, we will
prioritize the principles of research design and robust estimation and
inference using frequentist approaches.

## Prerequisites

There are two prerequisits for this class. First, students should have a
firm grasp of probability theory, statistical inference, and linear
models at the level of STAT I or an equivalent course ( e.g. do you
remember what the law of iterated expectations is? or what does it mean
for two random variables to be independent? or the significance of the
equation *β* = (*X*′*X*)<sup>−1</sup>(*X*′*Y*) ? ). Second, students
should have some background in writing scripts to implement statistical
analyses in <span class="proglang">R</span>. The course provides
foundational methodological training to Political Science PhD students
in their first or second year as part of their required sequence of
courses.

------------------------------------------------------------------------

## Requirements

### Homeworks (4 × 10 %)

You will receive homework about every two weeks. You will have to submit
your completed assignment within a week; exact deadlines will be made
clear on the assignment. You can work with others, but to receive
credit, your homework must comply with the following guidelines:

-   You must turn in a PDF copy of your own homework by the stated
    deadline to both the professor and TA.
-   The assignment that you turn in must clearly reflect your own
    thinking. Sets of verbatim copies of homework will have credit
    reduced by half.
-   Homework assignments may be hand written or typed, but they must be
    clearly legible.
-   Estimates obtained in <span class="proglang">R</span> must be
    formatted properly into tables or graphs resembling journal
    presentation styles. You should use a table formatting function
    (e.g., `kableExtra`, `apsrtable` or `stargazer` in
    <span class="proglang">R</span>). Use a reasonable (2 or at most 3)
    number of digits after decimal points, report standard errors or
    confidence intervals along with coefficients, clarify what are the
    dependent variables in each table or figure, and explain in
    footnotes to your tables or figures what kinds of estimators or
    adjustments have been used. Print outs of raw screen output or
    commented logs will not receive any credit. However, you may include
    such output as an appendix so that the grader can troubleshoot.
-   Mathematical derivations should include all key steps with
    explanations for important techniques.

Homework will be graded for points as indicated on each assignment and
count toward 40 % of your grade.

### Replications (2 × 20 %)

The primary objective of this course is to provide both a theoretical
understanding and practical experience in implementing the discussed
techniques. To achieve this, you are required to complete two
re-analyses of existing studies: one involving a Randomized Controlled
Trial (RCT) or experiment, and the other using an observational study.
Each student must select a paper at least one month before the
replication deadline and notify both the professor and the TA of their
choice. It is crucial to ensure that replication data is available for
the paper, typically through repositories like Harvard Dataverse or OSF.
If the data is not readily accessible online, you may contact the
authors or request assistance from the professor, but it is essential to
adhere to the deadlines.

Once you have selected your paper, you are expected to accomplish two
main tasks. First, replicate the primary analyses reported in the paper
using your own code, rather than the authors’ code from the replication
archive. Second, expand upon the main analyses in at least one of the
following ways:

1.  Check for robustness. For example, examine how the results depend on
    specific estimation models or measurement techniques.
2.  Alternatively, delve deeper into the logic of the authors’ theory.
    This may involve constructing new tests based on the implications of
    the authors’ theory or hypotheses.

For both tasks, you need to post a brief replication plan on the
Brightspace forum at least one week before submitting the replication
report.

Your final submission should include the data files you used and a
replication write-up in a reproducible <span class="proglang">R</span>
Markdown or Quarto Markdown file, enabling the professor and TA to
re-run your analyses on their machines. The write-up should encompass
the following:

-   A brief summary of the paper’s theory and hypotheses.
-   A concise description of the data, model, and main results (you may
    use screenshots from the paper to reference the main results).
-   A report on the replication of the main results (including code,
    output, and discussion of any diviations from original paper).
-   A report on the expansion of analyses (including code, output, and
    interpretation).

### Final Exam (20%)

A final exam will be scheduled during the final examination week (the
week of April 21st). The exam aims to assess individual progress, thus
allowing me to provide personalized recommendations for improving your
methodological foundations. If you cannot take the exam during the
scheduled period, you must provide notice at least one week in advance
so that we can arrange an alternative time. The final will constitute
20% of your grade.

------------------------------------------------------------------------

## Grading and Deadlines

-   **40% Homeworks** (due roughly every other week)  
-   **40% Replications** (due February 27th and April 17th)  
-   **20% Take-Home Final Exam** (Week of April 21st)

Late work will not be accepted without documented proof of a family or
medical emergency.

Problem sets and exam will have opportunities to earn extra credit,
theoretically meaning you could score above 100%. All grades are curved
without taking the extra credit results into consideration. The class
follow the standard Vanderbilt grading system: A 94+ | A- 90-93 | B+
87-89 | B 84-86 | B- 80-83 | C+ 77-79 | C 74-76 | C- 70-73 | D+ 67-69 |
D 64-66 | D- 60-63 | F \<60

------------------------------------------------------------------------

## Required Resources

### Software

You will have to work in <span class="proglang">R</span> in this class.
I encourage using [Quarto](https://quarto.org/) for your assignments.
This is a great investment that will pay off in the long run in terms of
productivity as well as reproducibility. Quarto Markdown runs easily
through RStudio or VS Code (or even many of its wrappers like
[Cursor](https://www.cursor.com/) or soon
[Positron](https://positron.posit.co/)). You can also check materials in
the repository I prepared for the Scientific Workflow workshop at
Vanderbilt here:
[github.com/gerasy1987/workflow_workshop](https://github.com/gerasy1987/workflow_workshop).

------------------------------------------------------------------------

### Textbooks

We will draw on textbooks and papers for the course. Here are the
**required** textbooks:

-   Angrist, Joshua D., and Jörn-Steffen Pischke. *Mostly Harmless
    Econometrics: An Empiricist’s Companion.* Princeton university
    press, 2009.
-   Gerber, Alan S and Donald P Green, . *Field Experiments: Design,
    analysis, and interpretation.* W.W. Norton, 2012.
-   Morgan, Stephen L., and Christopher Winship. *Counterfactuals and
    Causal Inference.* 2nd Ed. Cambridge University Press, 2015.

And here are the **recommended** ones:

-   Cattaneo, Matias D., Nicolás Idrobo, and Rocío Titiunik. *A
    Practical Introduction to Regression Discontinuity Designs:
    Foundations.* Cambridge University Press, 2019.
-   de Chaisemartin, Clément, and Xavier D’Haultfoeuille.
    *Difference-in-Differences for Simple and Complex Natural
    Experiments.* Forthcoming from Princeton University Press, 2023.
-   Ding, Peng. *A First Course in Causal Inference.* CRC Press, 2024.
-   Huber, Martin. *Causal Analysis.* MIT Press, 2023.
-   Humphreys, Macartan, and Alan M. Jacobs. *Integrated Inferences:
    Causal Models for Qualitative and Mixed-Method Research.* Cambridge
    University Press, 2023.
-   Imbens, Guido W., and Donald B. Rubin. *Causal Inference in
    Statistics, Social, and Biomedical Sciences.* Cambridge University
    Press, 2015.
-   Lohr, Sharon L. *Sampling: Design and Analysis.* CRC press, 2021.

You can obtain these as PDFs on Brightspace or on the authors’ websites
and online preprint archives (SSRN or arXiv). Papers are listed below
according to topic.

### Brightspace

Readings, lectures, assignments, and news for the course will be posted
on the course page on Brightspace (course management system used by
Vanderbilt). I will post announcements and changes to the home page of
the site, please keep an eye out. In addition, we will have discussion
forums for any class related questions and class related news/social
media posts on Brightspace.

------------------------------------------------------------------------

## Course Schedule

***Note:** The schedule is subject to change. Readings will be
distributed through Brightspace ahead of each class.*

<table>
<colgroup>
<col style="width: 10%" />
<col style="width: 20%" />
<col style="width: 40%" />
<col style="width: 30%" />
</colgroup>
<thead>
<tr>
<th style="text-align: center;">Date</th>
<th style="text-align: left;">Title</th>
<th style="text-align: left;">Topics</th>
<th style="text-align: left;">Readings</th>
</tr>
</thead>
<tbody>
<tr>
<th style="text-align: center;"><strong>1/7</strong></th>
<td style="text-align: left;">Welcome</td>
<td style="text-align: left;"></td>
<td style="text-align: left;"><a
href="problem_sets/quiz_refresher.pdf">probability quiz</a></td>
</tr>
<tr>
<th style="text-align: center;"><strong>1/9</strong></th>
<td style="text-align: left;">No class</td>
<td style="text-align: left;">SPSA</td>
<td style="text-align: left;"></td>
</tr>
<tr>
<th style="text-align: center;"></th>
<td colspan="3" style="text-align: left;"> <strong>PRIMER ON CAUSAL
INFERENCE</strong></td>
</tr>
<tr>
<th style="text-align: center;"><strong>1/14</strong></th>
<td style="text-align: left;">Probability Review / Introduction</td>
<td style="text-align: left;"></td>
<td style="text-align: left;"><ul>
<li><span class="citation" data-cites="samii2016causal">Samii (<a
href="#ref-samii2016causal" role="doc-biblioref">2016</a>)</span></li>
</ul></td>
</tr>
<tr>
<th style="text-align: center;"><strong>1/16 1/21</strong></th>
<td style="text-align: left;">Review (cont.) / What is
Identification?</td>
<td style="text-align: left;">observation versus intervention, potential
outcomes (ATE, ATT, probability of necessity), ATE under SUTVA and
strong ignorability, causal effects with potential outcomes</td>
<td style="text-align: left;"><ul>
<li><span class="citation" data-cites="gerber2012field">Gerber and Green
(<a href="#ref-gerber2012field" role="doc-biblioref">2012</a>, Ch.
2)</span></li>
<li><span class="citation" data-cites="angrist2009mostly">Angrist and
Pischke (<a href="#ref-angrist2009mostly" role="doc-biblioref">2009</a>,
Ch. 1-2)</span></li>
<li><span class="citation" data-cites="morgan2015counterfactuals">Morgan
and Winship (<a href="#ref-morgan2015counterfactuals"
role="doc-biblioref">2015</a>, Ch. 1-2)</span></li>
<li><span class="citation" data-cites="holland1986statistics">Holland
(<a href="#ref-holland1986statistics"
role="doc-biblioref">1986</a>)</span></li>
</ul></td>
</tr>
<tr>
<th style="text-align: center;"><strong>1/23 1/28</strong></th>
<td style="text-align: left;">Regression and Causality</td>
<td style="text-align: left;">CEF and its properties, selection on
observables, conditional ignorability</td>
<td style="text-align: left;"><ul>
<li><span class="citation" data-cites="angrist2009mostly">Angrist and
Pischke (<a href="#ref-angrist2009mostly" role="doc-biblioref">2009</a>,
Ch. 3.1-3.2.2)</span></li>
<li><span class="citation" data-cites="morgan2015counterfactuals">Morgan
and Winship (<a href="#ref-morgan2015counterfactuals"
role="doc-biblioref">2015</a>, Ch. 6.1-6.2)</span></li>
<li><span class="citation" data-cites="cinelli2024crash">Cinelli,
Forney, and Pearl (<a href="#ref-cinelli2024crash"
role="doc-biblioref">2024</a>)</span></li>
</ul></td>
</tr>
<tr>
<th style="text-align: center;"><strong>1/30</strong></th>
<td style="text-align: left;">The Truth about Regression</td>
<td style="text-align: left;">regression anatomy, omitted variable bias,
positivity assumption</td>
<td style="text-align: left;"><ul>
<li><span class="citation" data-cites="angrist2009mostly">Angrist and
Pischke (<a href="#ref-angrist2009mostly" role="doc-biblioref">2009</a>,
Ch. 3.2.3-3.5)</span></li>
<li><span class="citation" data-cites="morgan2015counterfactuals">Morgan
and Winship (<a href="#ref-morgan2015counterfactuals"
role="doc-biblioref">2015</a>, Ch. 6.3)</span></li>
<li><span class="citation" data-cites="clarke2005phantom">Clarke (<a
href="#ref-clarke2005phantom" role="doc-biblioref">2005</a>)</span></li>
<li><span class="citation" data-cites="aronow2016does">Aronow and Samii
(<a href="#ref-aronow2016does"
role="doc-biblioref">2016</a>)</span></li>
</ul></td>
</tr>
<tr>
<th style="text-align: center;"></th>
<td colspan="3" style="text-align: left;"> <strong>EXPERIMENTAL
DESIGNS</strong></td>
</tr>
<tr>
<th style="text-align: center;"><strong>2/4 2/6</strong></th>
<td style="text-align: left;">Basics of Experimental Design</td>
<td style="text-align: left;">target quantities (SATE, PATE), inference
for the SATE and PATE in an idealized experiment, randomization
inference</td>
<td style="text-align: left;"><ul>
<li><span class="citation" data-cites="gerber2012field">Gerber and Green
(<a href="#ref-gerber2012field" role="doc-biblioref">2012</a>, Ch.
3)</span></li>
</ul></td>
</tr>
<tr>
<th style="text-align: center;"><strong>2/11</strong></th>
<td style="text-align: left;">Complex Experimental Designs and Power
Analysis</td>
<td style="text-align: left;">MDE and power analysis, clustering,
stratification and block randomization, factorial designs</td>
<td style="text-align: left;"><ul>
<li><span class="citation" data-cites="gerber2012field">Gerber and Green
(<a href="#ref-gerber2012field" role="doc-biblioref">2012</a>, Ch.
4)</span></li>
</ul></td>
</tr>
<tr>
<th style="text-align: center;"></th>
<td colspan="3" style="text-align: left;"> <strong>OBSERVATIONAL DESIGNS
FOR CAUSAL INFERENCE</strong></td>
</tr>
<tr>
<th style="text-align: center;"><strong>2/13 2/18</strong></th>
<td style="text-align: left;">Matching</td>
<td style="text-align: left;">exact matching, coarsened exact matching,
nearest neighbor matching and bias correction, balance checking,
propensity score theorem</td>
<td style="text-align: left;"><ul>
<li><span class="citation" data-cites="angrist2009mostly">Angrist and
Pischke (<a href="#ref-angrist2009mostly" role="doc-biblioref">2009</a>,
Ch. 3)</span></li>
<li><span class="citation" data-cites="morgan2015counterfactuals">Morgan
and Winship (<a href="#ref-morgan2015counterfactuals"
role="doc-biblioref">2015</a>, Ch. 5)</span></li>
<li><span class="citation" data-cites="sekhon2009opiates">Sekhon (<a
href="#ref-sekhon2009opiates" role="doc-biblioref">2009</a>)</span></li>
<li><span class="citation" data-cites="caliendo2008some">Caliendo and
Kopeinig (<a href="#ref-caliendo2008some"
role="doc-biblioref">2008</a>)</span></li>
</ul></td>
</tr>
<tr>
<th style="text-align: center;"><strong>2/20 2/25</strong></th>
<td style="text-align: left;">Instrumental Variables</td>
<td style="text-align: left;">IV estimator, 2SLS, variance
estimation</td>
<td style="text-align: left;"><ul>
<li><span class="citation" data-cites="angrist2009mostly">Angrist and
Pischke (<a href="#ref-angrist2009mostly" role="doc-biblioref">2009</a>,
Ch. 4.1-4.2)</span></li>
<li><span class="citation" data-cites="morgan2015counterfactuals">Morgan
and Winship (<a href="#ref-morgan2015counterfactuals"
role="doc-biblioref">2015</a>, Ch. 9.1-9.2)</span></li>
<li><span class="citation"
data-cites="angrist1996identification">Angrist, Imbens, and Rubin (<a
href="#ref-angrist1996identification"
role="doc-biblioref">1996</a>)</span></li>
<li><span class="citation" data-cites="sovey2011instrumental">Sovey and
Green (<a href="#ref-sovey2011instrumental"
role="doc-biblioref">2011</a>)</span></li>
</ul></td>
</tr>
<tr>
<th style="text-align: center;"><strong>2/27</strong></th>
<td style="text-align: left;">Local Average Treatment Effects</td>
<td style="text-align: left;">IV with heterogeneous effects,
one-/two-sided non-compliance</td>
<td style="text-align: left;"><ul>
<li><span class="citation" data-cites="angrist2009mostly">Angrist and
Pischke (<a href="#ref-angrist2009mostly" role="doc-biblioref">2009</a>,
Ch. 4.3-4.7)</span></li>
<li><span class="citation" data-cites="morgan2015counterfactuals">Morgan
and Winship (<a href="#ref-morgan2015counterfactuals"
role="doc-biblioref">2015</a>, Ch. 9.3)</span></li>
</ul></td>
</tr>
<tr>
<th style="text-align: center;"><strong>3/4 3/6</strong></th>
<td style="text-align: left;">Panel Data</td>
<td style="text-align: left;">fixed and random effects, within
estimator, LSDV</td>
<td style="text-align: left;"><ul>
<li><span class="citation" data-cites="angrist2009mostly">Angrist and
Pischke (<a href="#ref-angrist2009mostly" role="doc-biblioref">2009</a>,
Ch. 5.1, 5.4)</span></li>
<li><span class="citation" data-cites="morgan2015counterfactuals">Morgan
and Winship (<a href="#ref-morgan2015counterfactuals"
role="doc-biblioref">2015</a>, Ch. 11.3)</span></li>
</ul></td>
</tr>
<tr>
<th style="text-align: center;"><strong>3/11 3/13 3/18</strong></th>
<td style="text-align: left;">No Class</td>
<td style="text-align: left;">Spring Break/New Faces</td>
<td style="text-align: left;"></td>
</tr>
<tr>
<th style="text-align: center;"><strong>3/20 3/25</strong></th>
<td style="text-align: left;">Difference-in-Differences</td>
<td style="text-align: left;">two-period DID, pre-trends, event study,
conditional DID, triple differences, continuous treatment DID, TWFE bias
with multiple events, event-by-event estimation</td>
<td style="text-align: left;"><ul>
<li><span class="citation" data-cites="angrist2009mostly">Angrist and
Pischke (<a href="#ref-angrist2009mostly" role="doc-biblioref">2009</a>,
Ch. 5.2)</span></li>
<li><span class="citation" data-cites="bertrand2004much">Bertrand,
Duflo, and Mullainathan (<a href="#ref-bertrand2004much"
role="doc-biblioref">2004</a>)</span></li>
</ul></td>
</tr>
<tr>
<th style="text-align: center;"><strong>3/27 4/1</strong></th>
<td style="text-align: left;">Synthetic Control</td>
<td style="text-align: left;">identification, estimation and statistical
inference, interactive FEs</td>
<td style="text-align: left;">TBD</td>
</tr>
<tr>
<th style="text-align: center;"><strong>4/3 4/8</strong></th>
<td style="text-align: left;">Regression Discontinuity Designs</td>
<td style="text-align: left;">parametric, non-parametric local
regression, optimized RD and honest inference, threats, fuzzy RDD
(?)</td>
<td style="text-align: left;"><ul>
<li><span class="citation" data-cites="angrist2009mostly">Angrist and
Pischke (<a href="#ref-angrist2009mostly" role="doc-biblioref">2009</a>,
Ch. 6)</span></li>
<li><span class="citation" data-cites="morgan2015counterfactuals">Morgan
and Winship (<a href="#ref-morgan2015counterfactuals"
role="doc-biblioref">2015</a>, Ch. 11.2)</span></li>
<li><span class="citation" data-cites="imbens2008regression">Imbens and
Lemieux (<a href="#ref-imbens2008regression"
role="doc-biblioref">2008</a>)</span></li>
<li><span class="citation" data-cites="de2016misunderstandings">De la
Cuesta and Imai (<a href="#ref-de2016misunderstandings"
role="doc-biblioref">2016</a>)</span></li>
</ul></td>
</tr>
<tr>
<th style="text-align: center;"></th>
<td colspan="3" style="text-align: left;"> <strong>ADDITIONAL
TOPICS</strong></td>
</tr>
<tr>
<th style="text-align: center;"><strong>4/10</strong></th>
<td style="text-align: left;">Mediation Effects</td>
<td style="text-align: left;">natural direct and indirect effects,
controlled direct and indirect effects, sensitivity analysis,
experimental designs</td>
<td style="text-align: left;"><ul>
<li><span class="citation" data-cites="gerber2012field">Gerber and Green
(<a href="#ref-gerber2012field" role="doc-biblioref">2012</a>, Ch.
10)</span></li>
</ul></td>
</tr>
<tr>
<th style="text-align: center;"><strong>4/15</strong></th>
<td style="text-align: left;">Moderator Effects</td>
<td style="text-align: left;">interaction effects and non-linear
conditional effect curves, decomposing effect heterogeneity, optimal
treatment regimes</td>
<td style="text-align: left;"><ul>
<li><span class="citation" data-cites="gerber2012field">Gerber and Green
(<a href="#ref-gerber2012field" role="doc-biblioref">2012</a>, Ch.
9)</span></li>
</ul></td>
</tr>
<tr>
<th style="text-align: center;"><strong>4/17</strong></th>
<td style="text-align: left;">Course Wrap-Up</td>
<td style="text-align: left;"></td>
<td style="text-align: left;"></td>
</tr>
</tbody>
</table>

## Class Policies

### Cell Phones, Laptops, Tablets, etc.

You are asked to silence your cell phone / tablet / smart watch before
class begins.

### Academic Honor Code

Students are expected to be familiar with and adhere to the Vanderbilt
University Academic Honesty policy, available at
[www.vanderbilt.edu/student_handbook/the-honor-system/](https://www.vanderbilt.edu/student_handbook/the-honor-system/).

While collaboration is a key component of the social sciences, it is
imperative that each student’s work on assignments reflects their own
efforts. Care must be taken to avoid plagiarism. Collaboration is
allowed on problem sets, but strictly prohibited on final exams and
replications.

Academic misconduct, which includes cheating, fabrication, plagiarism,
altering graded examinations for additional credit, having another
person take an examination, falsification of results, and facilitating
academic dishonesty, as specified further in the university policy, is
unacceptable and may result in penalties such as failure of the
assignment or course, as well as disciplinary actions at the program or
university level.

ChatGPT and other Large Language Models (LLMs) are acknowledged as
useful tools for social scientists and may be used as resources for
completing assignments and for achieving a deeper understanding of
course concepts. However, it is essential that students’ assignments are
not solely generated by these tools. All assignments must document the
ChatGPT prompts and outputs utilized.

### Accommodations for Learning or Access Disabilities

This course is designed to be inclusive and respectful of students of
all backgrounds, identities, and abilities. If there are barriers that
affect the learning environment or require specific arrangements (such
as those related to building evacuations), students are encouraged to
discuss these with the instructor as early as possible. The
confidentiality of these discussions will be respected. Students should
also contact the Vanderbilt Student Access office (
[www.vanderbilt.edu/student-access/](https://www.vanderbilt.edu/student-access/)
) to learn about specific accommodations and ensure they are provided in
a timely manner. Accommodations requests should be made within the first
three weeks of the semester, except under unusual circumstances.

### Mental Health

Students may encounter stressors that impact both their academic
performance and personal well-being. These can include academic
pressures and challenges related to relationships, mental health,
substance use, identities, or finances. If these challenges interfere
with academic success, students should reach out to the instructor to
explore potential solutions together. Vanderbilt offers the following
resources:

-   University Counseling Center: Provides individual and group therapy,
    psychiatric services, and assessments. Urgent Care Counseling is
    available in person from 9 am - 4 pm, Monday through Friday, or by
    phone 24/7. For more information, call 615-322-2571, visit
    [vu.edu/scn](http://vu.edu/scn), or connect with Student Care
    Coordination (SCC) where most referrals to the UCC begin.

-   Center for Student Wellbeing: Aims to support personal and academic
    success. Contact by calling 615-322-0480 or emailing
    <healthydores@vanderbilt.edu>.

-   Student Care Coordination: Assists students in accessing campus and
    community resources for academic and personal support. Call
    615-343-9355 or visit [vu.edu/scn](http://vu.edu/scn).

-   Crisis Text Line: For free 24/7 support, text VANDY to 741741.

-   National Suicide & Crisis Lifeline: Call or text 988 for
    confidential, round-the-clock support.

-   Vanderbilt Psychiatric Hospital: Offers 24/7 crisis assessment and
    admissions. Immediate help is available by calling 615-327-7000.

### Mandatory Reporting

Title IX makes it clear that violence and harassment based on sex and
gender are Civil Rights offenses subject to the same kinds of
accountability and support applied to offenses against other protected
categories such as race and national origin. If students or someone they
know has been harassed or assaulted, they can call the Project Safe
24-hour crisis/support hotline at 615-322-7233. A list of resources can
be found at Project Safe. The University’s Title IX Coordinator
(615-322-4705) is another contact point, where appropriate resources and
contacts for confidential support are available:
[www.vanderbilt.edu/title-ix/](https://www.vanderbilt.edu/title-ix/).

As faculty members, professors have responsibilities to help create a
safe learning environment on campus, regardless of identity or
circumstances. Professors also have a mandatory reporting
responsibility. It is the intention that students feel able to share
information related to their life experiences in classroom discussions,
written work, and one-on-one meetings. Faculty will seek to keep
information shared as private as possible. However, as representatives
of an institution that strives for safety for all people, professors are
mandatory reporters. University faculty, many staff members, and some
student leaders are required to report incidents of sexual assault,
sexual harassment, dating violence, domestic violence, stalking, and
child abuse, as well as any suspected discrimination (regarding age,
race, color, creed, religion, ancestry, national or ethnic origin,
sex/gender, sexual orientation, disability, genetic information,
military status, familial status, or other protected categories under
local, state, or federal law) to the University’s Title IX Coordinator
(615-322-4705), as required by University policy and state and federal
law. If an experience of interpersonal violence and/or child abuse is
disclosed to faculty or classmates with mandatory reporting duties,
whether in class discussion, through a course assignment, or in private
communication, the disclosure will be kept as private as possible but
may not remain confidential.

### Diversity Statement

Social science centers around creative thinking aimed at answering
challenging questions. Such creativity flourishes through exposure to
diverse perspectives that stem from varied experiences. Diversity in all
its forms, including age, ability or disability, ethnicity, national
origin, race, religion, sex, gender, sexual orientation, and family and
marital status, is highly valued in this class. It is expected that all
students will respect these differences and strive to understand how
others’ perspectives, behaviors, and worldviews may differ from their
own.

### Religious Holidays

Observing religious holidays and cultural practices is an important part
of reflecting diversity. As an instructor, the commitment is to provide
equivalent educational opportunities to students of all belief systems.
Students should review the course requirements at the beginning of the
semester to identify any foreseeable conflicts with assignments, exams,
or other required attendance. If possible, students are encouraged to
contact the instructor within the first two weeks of the first class
meeting to discuss and make fair and reasonable adjustments to the
schedule and/or tasks.

------------------------------------------------------------------------

## Acknowledgments

This course is largely based on the materials prepared for a previous
iteration of Statistics for Political Research III taught by [Bradley
Smith](https://bradleycarlsmith.com/) at Vanderbilt. Additionally, some
weeks draw on materials from similar classes taught by [Cyrus
Samii](https://cyrussamii.com/) at NYU and [Naoki
Egami](https://naokiegami.com/) at Columbia.

------------------------------------------------------------------------

## References

Angrist, Joshua D, Guido W Imbens, and Donald B Rubin. 1996.
“Identification of Causal Effects Using Instrumental Variables.”
*Journal of the American Statistical Association* 91 (434): 444–55.

Angrist, Joshua D, and Jörn-Steffen Pischke. 2009. *Mostly Harmless
Wconometrics: An Wmpiricist’s Companion*. Princeton University Press.

Aronow, Peter M, and Cyrus Samii. 2016. “Does Regression Produce
Representative Estimates of Causal Effects?” *American Journal of
Political Science* 60 (1): 250–67.

Bertrand, Marianne, Esther Duflo, and Sendhil Mullainathan. 2004. “How
Much Should We Trust Differences-in-Differences Estimates?” *The
Quarterly Journal of Economics* 119 (1): 249–75.

Caliendo, Marco, and Sabine Kopeinig. 2008. “Some Practical Guidance for
the Implementation of Propensity Score Matching.” *Journal of Economic
Surveys* 22 (1): 31–72.

Cinelli, Carlos, Andrew Forney, and Judea Pearl. 2024. “A Crash Course
in Good and Bad Controls.” *Sociological Methods & Research* 53 (3):
1071–1104.

Clarke, Kevin A. 2005. “The Phantom Menace: Omitted Variable Bias in
Econometric Research.” *Conflict Management and Peace Science* 22 (4):
341–52.

De la Cuesta, Brandon, and Kosuke Imai. 2016. “Misunderstandings about
the Regression Discontinuity Design in the Study of Close Elections.”
*Annual Review of Political Science* 19 (1): 375–96.

Gerber, Alan S, and Donald P Green. 2012. “Field Experiments: Design,
Analysis, and Interpretation.” *(No Title)*.

Holland, Paul W. 1986. “Statistics and Causal Inference.” *Journal of
the American Statistical Association* 81 (396): 945–60.

Imbens, Guido W, and Thomas Lemieux. 2008. “Regression Discontinuity
Designs: A Guide to Practice.” *Journal of Econometrics* 142 (2):
615–35.

Morgan, Stephen L, and Christopher Winship. 2015. *Counterfactuals and
Causal Inference*. Cambridge University Press.

Samii, Cyrus. 2016. “Causal Empiricism in Quantitative Research.” *The
Journal of Politics* 78 (3): 941–55.

Sekhon, Jasjeet S. 2009. “Opiates for the Matches: Matching Methods for
Causal Inference.” *Annual Review of Political Science* 12 (1): 487–508.

Sovey, Allison J, and Donald P Green. 2011. “Instrumental Variables
Estimation in Political Science: A Readers’ Guide.” *American Journal of
Political Science* 55 (1): 188–200.
