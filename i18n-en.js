/* HigGym — English translation bundle.
   Loaded by toolbar-annotated.html. The Korean text stays in the HTML;
   this file only supplies the English replacements applied on ?lang=en.
   Keys: entry id -> { h3, what, when, why, tip, u27, crit, ok, ng, cap[] } */
window.I18N_EN = {

meta: {
  title: `SwiftUI Toolbar · Text · Tab Bar · Sheets · Safe Area Bar · System Materials · Menu — annotated by topic (when · criteria · design intent)`,
  brand: `<span class="glass">Toolbar · Text · Tab Bar · Sheets · Safe Area Bar · System Materials · Menu</span> annotated by topic`,
  brandSub: `When · criteria · design intent — iOS 26 · iOS 27`,
  kicker: `● 68 topics fully annotated + 7 design principles`,
  h1: `Toolbar · Text · Tab Bar · Sheets · Safe Area Bar · System Materials · Menu, explained topic by topic — when, by what criteria, and why it was designed this way`,
  lede: `The original table of contents is kept intact, and <b>every topic</b> carries five notes:
        <span class="pill g">When to use it</span> /
        <span class="pill" style="color:var(--accent-2);border-color:rgba(123,108,255,.3);background:rgba(123,108,255,.08)">Why it is designed this way</span> /
        <span class="pill a">TIP</span> practical notes /
        <span class="pill g">Good examples</span> two real-app cases that pass the criterion /
        <span class="pill" style="color:var(--red);border-color:rgba(255,107,107,.3);background:rgba(255,107,107,.08)">Bad examples</span> two common misuses /
        <span class="pill" style="color:var(--dim);border-color:var(--line)">References</span> the sources behind that topic.
        The <b>mini preview</b> on the right of each topic shows where the element sits on screen (blue highlight).<br>
        The body text targets <b>iOS 26 (WWDC25)</b>; anything that changed afterwards is separated into an <span class="pill a">iOS 27 update</span> row (based on the WWDC26 announcements plus iOS 27 beta and press coverage, last updated 2026-07-17). All sources are on the <a href="#refs">references page</a>. Click an item in the left sidebar to jump straight to that topic's page.`,
  aria: {
    '#langTgl': `Korean / English`,
    '#sbOpen': `Show navigation`,
    '#sbClose': `Hide navigation`
  },
  refs: `<b>SwiftUI Toolbar · Text · Tab Bar · Sheets · Safe Area Bar · System Materials · Menu — 68 topics fully annotated + 7 design principles</b><br>
      Body text targets iOS 26 (WWDC25) · <span style="color:var(--amber)">iOS 27 update</span> rows are based on the WWDC26 announcements and iOS 27 beta/press coverage · last updated 2026-07-17<br>
      The prose in this document was synthesized and rewritten by an AI (Claude) from the sources below. It is not a direct quotation, so check the sources for exact wording.

      <p style="margin:20px 0 6px;color:var(--text);font-weight:700">References — Apple official (HIG)</p>
      <ul style="margin:0;padding-left:20px;line-height:2">
        <li><a href="https://developer.apple.com/design/human-interface-guidelines/toolbars">Human Interface Guidelines — Toolbars</a></li>
        <li><a href="https://developer.apple.com/design/human-interface-guidelines/tab-bars">Human Interface Guidelines — Tab bars</a></li>
        <li><a href="https://developer.apple.com/design/human-interface-guidelines/sheets">Human Interface Guidelines — Sheets</a></li>
        <li><a href="https://developer.apple.com/design/human-interface-guidelines/layout">Human Interface Guidelines — Layout</a></li>
        <li><a href="https://developer.apple.com/design/human-interface-guidelines/materials">Human Interface Guidelines — Materials</a></li>
        <li><a href="https://developer.apple.com/design/human-interface-guidelines/menus">Human Interface Guidelines — Menus</a></li>
        <li><a href="https://developer.apple.com/design/human-interface-guidelines/navigation-and-search">Human Interface Guidelines — Navigation &amp; search</a></li>
        <li><a href="https://developer.apple.com/design/human-interface-guidelines/typography">Human Interface Guidelines — Typography</a></li>
      </ul>

      <p style="margin:16px 0 6px;color:var(--text);font-weight:700">References — Apple official (WWDC sessions · API docs)</p>
      <ul style="margin:0;padding-left:20px;line-height:2">
        <li><a href="https://developer.apple.com/videos/play/wwdc2025/219/">WWDC25 — Meet Liquid Glass</a></li>
        <li><a href="https://developer.apple.com/videos/play/wwdc2025/356/">WWDC25 — Get to know the new design system</a></li>
        <li><a href="https://developer.apple.com/videos/play/wwdc2025/323/">WWDC25 — Build a SwiftUI app with the new design</a></li>
        <li><a href="https://developer.apple.com/documentation/swiftui/tabrole/prominent">Apple Developer Documentation — TabRole.prominent (iOS 27)</a></li>
      </ul>

      <p style="margin:16px 0 6px;color:var(--text);font-weight:700">References — iOS 27 (WWDC26) changes</p>
      <ul style="margin:0;padding-left:20px;line-height:2">
        <li><a href="https://swiftwithmajid.com/2026/06/08/what-is-new-in-swiftui-after-wwdc26/">Swift with Majid — What is new in SwiftUI after WWDC26</a></li>
        <li><a href="https://mjtsai.com/blog/2026/06/19/swiftui-in-appleos-27/">Michael Tsai — SwiftUI in appleOS 27</a></li>
        <li><a href="https://www.sagarunagar.com/blog/swiftui-prominent-tab-is-not-a-floating-action-button">Sagar Unagar — SwiftUI's New .prominent Tab in iOS 27 Is Not a Floating Action Button</a></li>
        <li><a href="https://mjtsai.com/blog/2026/01/09/search-vs-primary-action-in-the-ios-26-tab-bar/">Michael Tsai — Search vs. Primary Action in the iOS 26 Tab Bar</a></li>
        <li><a href="https://9to5mac.com/2026/05/13/ios-27s-new-design-leak-sounds-a-lot-like-what-ive-been-wanting-most/">9to5Mac — iOS 27's new design leak (reports of a merged search tab and the removal of tab bar minimization)</a></li>
        <li><a href="https://www.macrumors.com/2026/06/03/ios-27-app-rumors/">MacRumors — iOS 27: All the Rumored App Features</a></li>
        <li><a href="https://www.aprenderhub.com/2026/05/ios-27-tab-bar-fix-liquid-glass.html">AprenderHub — iOS 27 Tab Bar Fix: Apple's Liquid Glass Course Correction</a></li>
      </ul>

      <p style="margin:16px 0 6px;color:var(--text);font-weight:700">References — community write-ups (iOS 26)</p>
      <ul style="margin:0;padding-left:20px;line-height:2">
        <li><a href="https://nilcoalescing.com/blog/SwiftUISearchEnhancementsIniOSAndiPadOS26/">nil coalescing — SwiftUI Search Enhancements in iOS and iPadOS 26</a></li>
        <li><a href="https://www.createwithswift.com/exploring-a-new-visual-language-liquid-glass/">Create with Swift — Exploring a New Visual Language: Liquid Glass</a></li>
        <li><a href="https://www.learnui.design/blog/ios-design-guidelines-templates.html">Learn UI Design — iOS Design Guidelines</a></li>
      </ul>`
},

labels: {
  when: `When to use it`,
  why:  `Why it is designed this way`,
  tip:  `Tip`,
  ok:   `Good examples`,
  ng:   `Bad examples`,
  u27:  `iOS 27 update`,
  crit: `Criterion`,
  ref:  `References`
},

nav: {
  '#ch8': `<span class="n">8</span> Design Principles &amp; Criteria`,
  '#p3': `3. The grammar of position &amp; grouping`,
  '#p4': `4. Legibility &gt; aesthetics`,
  '#p5': `5. Space is a contract, text is variable`,
  '#p6': `6. Separate data from its presentation`,
  '#p7': `7. Direct manipulation`
},

navTitles: {
  '8.1 원칙별 기준과 사례': `8.1 Criteria and cases per principle`
},

ch: {
  ch8: `Design Principles &amp; Criteria <span class="ch-sub">— verified through good and bad examples</span>`
},

sec: {
  '1.1': {h2:`Items`, desc:`The nine cases are ultimately combinations of <b>three variables</b> — position (top leading/trailing · principal · bottom), count (single vs. cluster), and what happens when space runs out (overflow). They run from simple to complex.`},
  '1.2': {h2:`Title Display Modes`, desc:`A title is the device that says "what this screen is." You choose one by <b>hierarchy depth (root or detail) × content density × whether the title needs to become a control</b>.`},
  '1.3': {h2:`Scroll Edge Effects`, desc:`The fundamental reason this feature exists: because the toolbar <b>floats above the content as translucent glass</b>, controls can become unreadable when busy content passes underneath. Edge effects are a <b>safeguard for legibility</b>, which is why they are on by default. There is only one criterion — <b>"how complex is the content that will scroll behind the bar?"</b>`},
  '1.4': {h2:`Search`, desc:`Placement follows the <b>status of search</b> on this screen: is it ① the star, ② a frequently used supporting role, or ③ an occasional bit part? The big change in iOS 26 — search moved <b>from the top to the bottom</b> (reachability).`},
  '2.1': {h2:`Text Behavior`, desc:`The essence of text is that you cannot predict how long the content will be. All five cases are different answers to one problem — <b>"space is finite, text is variable"</b>: cut it (limit · truncation), shrink it (scale), reserve for it (range), or let the user take it (selection).`},
  '2.2': {h2:`Text Formatting`, desc:`There is one core principle — <b>never assemble data into strings by hand.</b> Units, names, dates and numbers follow different conventions in every locale, so you hand the data to a <span class="pill">FormatStyle</span> and leave the presentation to the system. That is the whole reason this family of APIs exists.`},
  '3.1': {h2:`Tab Items`, desc:`Tab items are <b>the labels of your app's top-level structure</b>. Two criteria decide the details — does the icon alone carry the meaning (label style), and is there a state that must call the user back (badge)?`},
  '3.2': {h2:`Tab Counts`, desc:`The number of tabs <b>is your information architecture</b>. Three to five is the standard range — fewer, and you should ask "are tabs the right control?"; more, and you should ask "is the structure right?"`},
  '3.3': {h2:`Visibility`, desc:`The criterion is <b>the screen's primary task</b> — if navigating is the primary task, keep the tab bar; if consuming (reading, viewing) is, let it step back.`},
  '3.4': {h2:`Search`, desc:`There is one question — is search <b>"one destination" or "a separate mode"</b>? iOS 26 introduced the search role (a detached capsule) for the latter, and iOS 27 (WWDC26) <b>opened that detached slot to non-search tabs via the prominent role</b>.`},
  '3.5': {h2:`Bottom Accessory`, desc:`<span class="pill">.tabViewBottomAccessory</span> — a <b>global state view that lives on the layer above the tab bar</b> (a mini player, for example). New in iOS 26, it standardizes the Music app pattern as a system API.`},
  '4.1': {h2:`Configurations`, desc:`The key variables of a sheet are its <b>detent (resting height)</b> and its <b>modality</b> — how much of the screen it takes, and how it relates to the content behind it (block vs. work alongside). That is all five cases in a nutshell.`},
  '4.2': {h2:`Full Screen Cover`, desc:`A sibling of the sheet with the opposite character — <b>it covers everything behind it and cannot be swiped away: a strong modal</b>. The criterion is "is this a flow the user must not leave by accident?"`},
  '4.3': {h2:`Transitions`, desc:`A transition is <b>the answer to "where did this screen come from?"</b> — if the origin carries no meaning, use standard (from the bottom); if the tapped element <i>is</i> the thing that opens, use zoom (expanding in place).`},
  '5.1': {h2:`Vertical Safe Area Bars`, desc:`<span class="pill">.safeAreaBar(edge:)</span> — the iOS 26 API that promotes a custom view into a "bar." Like a system bar, it <b>insets content automatically and participates in scroll edge effects</b>. A superset of overlay (which covers) and safeAreaInset (which only insets).`},
  '5.2': {h2:`Horizontal Safe Area Bars`, desc:`Safe areas are not only top and bottom — the same grammar applies to <b>the leading and trailing edges (notch and bezel in landscape)</b>. Only the edge changes; the concept (inset + effects) is identical.`},
  '6.1': {h2:`Materials`, desc:`A material is not a color but <b>a relationship with the background</b> — a translucent layer that shows what is behind it through blur and saturation adjustment, so the same material wears a different face on a different background. That is why this demo shows it "over several backgrounds."`},
  '6.2': {h2:`Vibrancy`, desc:`If a material is "glass," vibrancy is <b>how you etch onto that glass</b> — content on top of a material renders by drawing in the background's color, so it stays crisp instead of detaching.`},
  '7.1': {h2:`Menu`, desc:`A menu is the definitive device for <b>"UI that appears only when asked for"</b> — normally the presence of a single button, and on tap the full set of choices. It is the minimization principle applied to a list of actions.`},
  '8.1': {h2:`Criteria and cases per principle`, desc:`The principles running through the good and bad examples of all 68 topics in chapters 1–7 come down to <b>seven</b>. Each principle defines <b>its criterion in one sentence</b>, then contrasts <span class="pill g">good examples</span> that pass it with <span class="pill" style="color:var(--red);border-color:rgba(255,107,107,.3);background:rgba(255,107,107,.08)">bad examples</span> that violate it. The numbers in parentheses point to the matching topic in the body.`}
},

entries: {

i1: {
  what: `The minimal configuration — <b>a single button</b> at the top right. One glass capsule floating on its own.`,
  when: `When the screen has <b>exactly one</b> meaningful action — Edit, Done, Add (+), Share. If there really is only one action, the right answer is to keep this shape rather than inflate it.`,
  why: `On iOS, trailing is <b>the conventional home of the primary action</b>. It sits on the diagonal of the right thumb, and since leading is already claimed by Back there is no conflict. One button means one glass capsule — minimum visual weight (content-first).`,
  tip: `Building a bottom bar for a screen with a single action is overkill. The bottom bar is for actions you press <b>often and repeatedly</b>.`,
  ok: `① A single <b>Done</b> button at the top right of a note detail screen ② A single <b>+</b> (new item) on a list screen — one action, one shape`,
  ng: `① Only one action exists, yet decorative Share/Star buttons are added just to fill the capsule ② The one action is floated over the content as a custom button instead of the system slot`,
  cap: [`A single action capsule at the <b>top right (trailing)</b>`]
},
i2: {
  what: `Several buttons on the left bound into <b>one glass cluster</b>, with a single button on the right.`,
  when: `When the left holds <b>related supporting tools</b> (view switch, sort, filter as a set) and the right holds <b>one decisive action</b> (Done, Save) — a screen where "tools vs. decision" splits cleanly.`,
  why: `In Liquid Glass, <b>grouping is meaning</b>. Anything inside the same capsule reads as "one set." Keeping the left group (the toolset) separate from the single right button (the decision) prevents their roles from being misread.`,
  tip: `A cluster on the leading side competes with the Back button. It is mostly a pattern for root screens or modals — <b>screens with no back</b>.`,
  ok: `① Files — view switch and sort grouped on the left, <b>Select</b> on the right ② A document editor — undo/redo grouped on the left, <b>Done</b> on the right`,
  ng: `① Binding <b>Delete + Sort</b> into one capsule so two unrelated things look like a set ② Putting a cluster in the leading slot of a pushed detail screen, colliding with Back`,
  cap: [`A tool cluster on the <b>left</b> + a single decisive action on the <b>right</b>`]
},
i3: {
  what: `Multiple items on both sides — one capsule on the left, one on the right, forming <b>two independent groups</b>.`,
  when: `When there are many actions and they split into <b>two kinds</b>. For example: left = navigation/viewing, right = content manipulation. The top of tool-heavy productivity apps (document and photo editors).`,
  why: `<b>The gap between the two capsules is itself information</b> — a signal that "these two groups do different jobs." Cram everything into one capsule and unrelated features read as a single lump, raising cognitive load.`,
  tip: `Two or three per group is about right. Beyond that, consider the next topic (overflow) or spreading them to a bottom bar.`,
  ok: `① Photo editing — viewing/compare tools on the left, crop and filter tools on the right ② Browser chrome — back/forward (navigation) on the left, share and tab switching on the right`,
  ng: `① Six unrelated actions <b>split mechanically</b> three and three (violating grouping = meaning) ② The same feature (Share) duplicated in both capsules`,
  cap: [`<b>Two independent clusters</b> — the gap between them signals "different jobs"`]
},
i4: {
  what: `A single item in the <b>bottom toolbar</b> (<span class="pill a">.bottomBar</span>), shown as floating glass.`,
  when: `The one core action you press <b>most often and most repeatedly</b> on that screen — "New Message" in Mail, "New Note" in Notes. The higher the frequency, the lower it goes.`,
  why: `<b>Reachability (thumb reach)</b> is the entire reason. On a large display the top is hard to reach one-handed while the bottom is the thumb's home ground. It is the same logic that moved search to the bottom in iOS 26, and the background for "bottom placement is the default direction."`,
  tip: `On a screen with a tab bar you are sharing the bottom, so tread carefully — you must not blur the split between tab bar (navigation) and toolbar (actions).`,
  ok: `① <b>New Message</b> in Mail ② <b>New Note</b> in Notes — the most repeated action on that screen`,
  ng: `① Putting <b>Settings</b>, used once a month, at the bottom (violating the frequency criterion) ② Placing a destructive action like <b>Delete</b> alone in the easiest spot to hit`,
  cap: [`<b>Bottom (.bottomBar)</b> — a high-frequency action where the thumb lands`]
},
i5: {
  what: `A custom control placed in <b>the dead-center slot</b> where the title would go (<span class="pill p">.principal</span>), replacing the title.`,
  when: `When that control <b>is the identity of the screen</b> — a "Map/List" segmented control, a period picker: a switch that <b>governs the entire content of the screen</b>. A plain action button does not belong here.`,
  why: `The center is the anchor for the eye and <b>the slot that says "what this screen is."</b> Putting a control there instead of a title means "the identity of this screen changes with this control's value." It is the strongest slot in the hierarchy, so overusing it blurs the screen's focus.`,
  tip: `Using principal removes the title, so first check that the control explains the screen's identity well enough on its own.`,
  ok: `① The <b>Map/Satellite/Transit</b> segmented control in Maps ② A period picker in a stocks app (1D/1W/1Y) — change the value and the whole screen changes`,
  ng: `① A <b>Share</b> button, unrelated to the screen's identity, planted dead center ② A brand logo unrelated to the content placed in principal, removing the title`,
  cap: [`<b>Dead center (principal)</b> — the title slot taken over by the control that defines the screen`]
},
i6: {
  what: `A key control in the center plus one supporting action on the right — a combination of the two patterns above.`,
  when: `When you need <b>both</b> a control that switches the screen's mode (center) and an action that is always needed regardless of that mode (right — More, Settings, and so on).`,
  why: `It expresses <b>the difference in hierarchy</b> through position — center = the definition of the screen, trailing = an additional action. Even on the same line they are split into separate glass capsules, so there is no confusion.`,
  tip: `A wide principal control (a long segmented control) competes with trailing for space, so keep trailing to about one icon button.`,
  ok: `① A Map/List segmented control + More (⋯) on the right ② A calendar view switch (Day/Week/Month) + a <b>Today</b> button on the right`,
  ng: `① A five-segment control plus three trailing buttons — clipped by the fight for space ② An action button in the center and the mode control in trailing (hierarchy inverted)`,
  cap: [`Center control + <b>supporting action on the right</b> — hierarchy split by position`]
},
i7: {
  what: `When trailing holds more items than fit, the system <b>automatically folds the rest into a … (overflow) menu</b>.`,
  when: `Screens with four or more actions, when you need to split <b>the few worth exposing</b> from <b>the many that can be folded away</b>. Rare actions and destructive ones (Delete) go into overflow deliberately.`,
  why: `A compromise between two principles — offer every feature (completeness) without cluttering the screen (content-first). Also, shrinking buttons indefinitely to fit would make <b>touch targets smaller than a fingertip</b>, so the system folds them automatically to guarantee the minimum target size. That is why "fold when there are many" is the default behavior.`,
  tip: `What ends up in overflow is controlled by declaration order and priority. Design that order so you never fold away "the thing people use most."`,
  u27: `WWDC26 added <span class="pill">visibilityPriority(_:)</span>, letting you <b>specify directly which items survive on screen</b> when space gets tight. The overflow menu itself can also be shaped with <span class="pill">ToolbarOverflowMenu</span> — the "my most-used action got folded" problem solved at the API level.`,
  ok: `① A documents app — only the two essentials (Share, Edit) exposed, with Export, Print and Version History in overflow ② <b>Delete</b> deliberately kept inside overflow (guarding against mis-taps)`,
  ng: `① The most-used action, <b>Save</b>, folded into overflow because of declaration order ② Seven icons crammed in to avoid overflow, making touch targets smaller than a finger`,
  cap: [`Overflowing items fold automatically into the <b>⋯ menu</b>`]
},
i8: {
  what: `Placing <b>an arbitrary SwiftUI view</b> (text, status, a progress bar, a slider) in the bottom toolbar instead of a button.`,
  when: `When the bottom should show <b>status plus actions</b> together — Safari's address field, Mail's "Updated Just Now" + compose button, playback controls, and so on.`,
  why: `The design view that the bottom bar is not a row of buttons but <b>"the cockpit of the current page."</b> It gathers the information you check often and the controls you use often into one place near the thumb — reachability extended to information itself.`,
  tip: `Custom views also sit on glass, so painting a background color on the view fights the glass effect. Leave the background to the system.`,
  ok: `① Safari's bottom address field ② Mail's "Updated Just Now" status text + the compose button`,
  ng: `① An opaque background color on the custom view, laying a plank on top of the glass ② An ad banner in the bottom bar — a violation of the "cockpit" slot's grammar`,
  cap: [`<b>Status + action</b> in the bottom bar — the cockpit of the current page`]
},
i9: {
  what: `The full configuration, using leading · principal · trailing · bottom <b>all at once on one screen</b>.`,
  when: `On full-featured screens (editors, browsers) that need <b>every position to carry its share</b> — top: navigation and commitment, center: mode, bottom: high-frequency actions.`,
  why: `Because each position was given a distinct meaning (top = move/decide, center = identity, bottom = frequency), even the combination reads as <b>one consistent grammar</b>. That per-position grammar is what lets users predict where a button will be in an app they have never opened — the reason the system standardized positions in the first place.`,
  tip: `Filling every slot is not the goal. Put only what fits each slot's grammar there and leave the rest empty or in overflow.`,
  ok: `① A browser — top: navigation and share, bottom: address field + tab switching ② A photo editor — top: Cancel/Save, center: edit mode, bottom: detailed tools`,
  ng: `① Distributing buttons to every position out of the misconception that "an empty slot = failure" ② The same action (Share) duplicated at both the top and the bottom`,
  cap: [`<b>Top · center · bottom</b> all combined — a different grammar in each slot`]
}

,
t1: {
  what: `A <b>34pt large title</b> below the navigation bar. It shrinks automatically into the small inline title as you scroll.`,
  when: `<b>Root / top-level screens</b> and browsing lists (Settings, mailboxes, a library) — entry points where the user needs a strong sense of "where am I?"`,
  why: `On arrival, <b>orientation</b> matters more than content → make it big. Once reading starts, content matters → it collapses on scroll (the minimization principle). This default behavior is "big when needed, out of the way when not," applied to the title.`,
  tip: `A large title eats a lot of the first screen, so it is a poor fit where the top content must be visible immediately (chat, for instance).`,
  ok: `① The big "Settings" title on the Settings root ② A top-level list like the Music library, where "where am I?" matters`,
  ng: `① Large on every screen down to the third level — title size no longer expresses hierarchy ② Large on a chat screen — the conversation is pushed down from the very first frame`,
  cap: [`A <b>34pt large title</b> under the nav bar — collapses on scroll`]
},
t2: {
  what: `Keeps the presence of a large title but <b>pins it inside the nav bar (the inline position)</b>, so scrolling never pushes it away. New in iOS 26.`,
  when: `When you want the title to have weight but <b>do not want the layout bobbing as the user scrolls</b> — screens whose top must stay stable.`,
  why: `A compromise added <b>because the middle ground was empty</b> between Large (present but dynamic) and Inline (stable but faint). It is especially steady on a glass toolbar, where the relative positions of title and items stay fixed.`,
  tip: `As a new iOS 26 mode, official guidance is still thin. Compare it against large/inline on a real device before deciding.`,
  ok: `① A dashboard home that needs presence without scroll bobbing ② A screen where the title and buttons on a glass toolbar must hold their relative positions`,
  ng: `① Inline Large on a deep detail screen — overstated hierarchy ② Applying it everywhere purely because you dislike Large's collapse animation`,
  cap: [`A big title <b>pinned inside the nav bar</b> — it holds its position while scrolling`]
},
t3: {
  what: `The <b>17pt small title</b> centered in the nav bar. The most compact form.`,
  when: `<b>Detail screens, deep hierarchies, modal sheets</b>, and dense content. "Root = Large, detail = Inline" is the base formula; when in doubt, Inline is the safe pick.`,
  why: `On a detail screen the user already arrived with the context, so the title's job is small → save vertical space to show <b>one more line of content</b> (content-first). It also expresses hierarchy: title size hints at depth.`,
  tip: `When a screen pushed from a Large root is Inline, the change in size itself becomes a navigation signal: "you went one level in."`,
  ok: `① A mail detail screen ② The title at the top of a modal sheet — screens entered with the context already known`,
  ng: `① Standardizing on Inline even for root screens, losing the sense of orientation at the entry point ② Leaving a long title to be truncated forever instead of shortening it`,
  cap: [`The centered <b>17pt small title</b> — the default for detail screens and modals`]
},
t4: {
  what: `An <b>extreme case</b>: an inline title plus <b>five items</b> sharing one narrow nav bar.`,
  when: `Less a "do it this way" than a demonstration of <b>"what the system does when you push this much in."</b> If you genuinely need five, this is where you check the space negotiation between title and items and the overflow behavior.`,
  why: `The system is designed to prioritize and negotiate automatically — <b>shrinking the title or folding items</b> — so you do not have to branch on device width. That is why "degrade gracefully instead of breaking" is the default behavior.`,
  tip: `Needing five items up top is usually a design signal. Consider moving some to a bottom bar or overflow first.`,
  ok: `① A professional screen such as a PDF viewer that truly needs five tools, leaving the negotiation to the system ② Designing and verifying which item folds first on a narrow device`,
  ng: `① Hand-rolling a custom nav bar to force all five to stay visible ② Squeezing the type instead of reducing the item count when the title gets clipped`,
  cap: [`Title vs. <b>five items</b> negotiating for space — the system adjusts automatically`]
},
t5: {
  what: `A chevron (⌄) appears beside the title, and <b>tapping the title opens a menu</b> (<span class="pill">toolbarTitleMenu</span>).`,
  when: `When the title <b>is something you can change</b> — the current folder / account / document name is the title and tapping it switches, renames, or duplicates it. The classic pattern in Files and document editors.`,
  why: `Turning "actions on the title" into a separate button forces users to infer the relationship between the title and that button. <b>Letting them tap the object itself</b> removes the need to explain the relationship — the direct manipulation principle. It also saves a toolbar button.`,
  tip: `The menu should only hold actions on "the thing the title names." Put screen-wide actions in it and the grammar breaks.`,
  ok: `① Files — tap the folder title → Rename, Duplicate, Tags ② Mail — tap the title → switch account/mailbox`,
  ng: `① Wiring an app-wide settings menu, unrelated to the title, to the title ② Making it tappable without the chevron, so nobody discovers it`,
  cap: [`<b>Tap the title</b> to open a menu — for when the title is "something you can change"`]
},
t6: {
  what: `<b>A custom view in the large title slot</b> instead of plain text — a logo, avatar + name, special formatting.`,
  when: `When you need <b>brand or context</b> that text alone cannot carry — a logo on the app home, avatar + name on a profile screen, an emphasized date in a journal.`,
  why: `The title slot is the slot for the screen's identity, and identity is not always pure text, so the system <b>keeps the slot and opens up only its contents</b>. System behaviors such as collapse on scroll are inherited, keeping things consistent.`,
  tip: `Even a custom view must behave "like a title" — putting buttons or text fields in here violates the slot's grammar.`,
  ok: `① A profile screen — avatar + name ② A journal app — custom formatting that emphasizes the date`,
  ng: `① A custom view that never implements the collapse-on-scroll behavior, feeling foreign next to other screens ② A mini dashboard with a search field and buttons stuffed into the title slot (abusing the slot)`,
  cap: [`<b>A custom view — logo, avatar</b> — in the large title slot`]
},
s1: {
  what: `A <b>diffused fade</b> with no border. Content dissolves gently underneath the glass.`,
  when: `<b>Most ordinary screens.</b> Content of average brightness and contrast — text lists, card feeds. When in doubt, soft (the value automatic usually picks).`,
  why: `A divider line is a visual element in itself, so it <b>adds weight to the UI</b>. "Seeping through" rather than "being cut off" matches the material metaphor of glass and breaks immersion less — hence the default.`,
  tip: `Decide in this order: only when controls feel hard to read on soft should you step up to hard.`,
  ok: `① As the default for ordinary content such as text lists and card feeds ② Settings-style screens with few images`,
  ng: `① Soft on tables or grids where compartments matter — the boundary location becomes vague ② Soft above a bottom input field — the start of the input area is ambiguous`,
  cap: [`A fade where content <b>seeps away softly</b>, with no divider — the default`]
},
s2: {
  what: `A crisp <b>divider line</b> that cuts cleanly, clearly separating the content area from the bar area.`,
  when: `UI whose area boundaries <b>must be unmistakable</b> — above a bottom input field or accessory, structural content like tables and grids, or anywhere you must declare "controls start here."`,
  why: `Soft's diffusion is elegant but <b>blurs where the boundary is</b>. On a screen where compartments matter, that ambiguity is a cognitive cost — a clear line is the right answer. This is the option that picks clarity over atmosphere.`,
  tip: `Mixing soft and hard across screen types within one app is fine, but keep screens of the same kind consistent.`,
  ok: `① A clear divider above a chat input field ② Spreadsheet and table screens — content whose structure must read clearly`,
  ng: `① Hard on a serene photo feed — an unnecessary line that breaks immersion ② Mixing soft and hard screen by screen with no rule, losing consistency`,
  cap: [`A crisp <b>divider</b> separating the bar area from content`]
},
s3: {
  what: `A hard edge plus a toolbar background made of <b>thick, nearly opaque material</b>. The configuration for maximum legibility.`,
  when: `Screens where complex content — <b>photos, video, high-contrast graphics</b> — passes behind the bar. The last resort when the translucency of soft/hard buries the control labels.`,
  why: `A known weakness of Liquid Glass is <b>"insufficient contrast over busy backgrounds."</b> When transparency (aesthetics) collides with legibility (accessibility), legibility wins — so the system officially provides an escape hatch that gives up transparency. The same philosophy as the automatic response to the Reduce Transparency accessibility setting.`,
  tip: `The moment you get a review saying "pretty but unreadable," reach for this combination without hesitation. Legibility outranks aesthetics.`,
  ok: `① A toolbar floating over a photo grid — the last resort for securing legibility ② A control bar over a map (busy background passing under it at all times)`,
  ng: `① Thick material even over a plain white list — overkill that feels stuffy ② Keeping the transparency "because it looks nicer" while the labels are buried (legibility > aesthetics inverted)`,
  cap: [`Over busy backgrounds like photos and video — a <b>nearly opaque background</b> secures legibility`]
},
s4: {
  what: `The edge effect <b>turned off entirely</b>. Content passes under the bar with no treatment at all.`,
  when: `Only when the background is <b>reliably simple and uniform</b>, so overlap causes no legibility problem, or when the layout never lets content reach behind the bar. <b>An exceptional choice.</b>`,
  why: `The effect is a visual element too, so <b>removing it where it is not needed fits content-first</b>. The system still ships it on by default because "cases where it must be on" vastly outnumber "cases where off is safe" — turn it off only when you personally guarantee that safety.`,
  tip: `With it off, check dark mode, landscape, and large text settings too. Verify in one condition only and it will break in another.`,
  ok: `① A fixed layout whose content never reaches under the bar ② A screen with a reliably uniform solid background`,
  ng: `① Turning it off on a photo feed — scroll and the button labels blend into the photos ② Disabling it app-wide because "it looks more minimal"`,
  cap: [`The effect <b>fully off</b> — content passes straight under the bar (simple backgrounds only)`]
}

,
q1: {
  what: `The search field placed <b>in the toolbar</b> — a glass capsule at the bottom on iPhone, top trailing on iPad.`,
  when: `The standard pick for screens where search is <b>used often</b>. For a new screen built on iOS 26, it is effectively the first candidate.`,
  why: `The old top-mounted search put the most frequently used feature in <b>the hardest place to reach one-handed</b>. iOS 26 resolves that contradiction — the system places it <b>to match each device's ergonomics</b>: near the thumb at the bottom on iPhone, at the natural top trailing for a two-handed grip on iPad.`,
  tip: `On iOS 26, <code>.searchable()</code> with no explicit placement (automatic) generally resolves to this position too.`,
  ok: `① A bottom search capsule on a list where search is the main feature, like Contacts ② Accepting the automatic top trailing placement on iPad as-is`,
  ng: `① Permanently exposing a search field on a screen where search is barely used ② Pinning it to the top with custom code on iPhone — ignoring thumb reach`,
  cap: [`A <b>bottom glass capsule</b> on iPhone · top trailing on iPad`]
},
q2: {
  what: `A configuration where <b>the search field and other buttons coexist</b> in the bottom toolbar.`,
  when: `Screens where search is frequent <b>and so are actions like compose or filter</b> — a mailbox (search + new message) or Notes (search + new note) are the archetypes.`,
  why: `When two or more features are high-frequency, <b>both belong at the bottom</b> for reachability to stay consistent. Declare search's slot with <span class="pill">DefaultToolbarItem(kind:.search)</span> and separate it with <span class="pill g">ToolbarSpacer</span> — search (input) and buttons (actions) are different in nature, so they should read as <b>different capsules</b>.`,
  tip: `Search plus two or more buttons at the bottom is overcrowded. Search + one core action is the balance point.`,
  ok: `① A mailbox — the search capsule and the compose button split into separate capsules ② A note list — search coexisting with a new-note button`,
  ng: `① Binding the search field and an action button into <b>the same capsule</b> (mixing input with action) ② Search plus three buttons at the bottom — an overcrowded capsule that invites mis-taps`,
  cap: [`<b>Search + action</b> together at the bottom — capsules split by ToolbarSpacer`]
},
q3: {
  what: `A search bar in the <b>drawer beneath the nav bar title</b> — the traditional position (pre-iOS 25). By default it <b>collapses on scroll</b>.`,
  when: `List screens where search is a <b>supporting feature</b> and the "pull down to find" convention feels natural, or when you must preserve familiar behavior in an existing app.`,
  why: `It collapses on scroll by default because scrolling signals that the user is <b>reading, not searching</b> — so no vertical space goes to an unused search bar (minimization). The convention of pulling back to the top to bring it out is already learned.`,
  tip: `For a new iOS 26 screen, consider toolbar placement first; pick the drawer when the goal is "keep the existing convention."`,
  ok: `① Supporting search on a settings-style list you scan top to bottom ② A staged migration for an app where consistency with older versions matters`,
  ng: `① Putting search in a drawer that disappears on scroll when search is the core of the app ② Offering drawer search and bottom search at the same time (duplicated slots)`,
  cap: [`The <b>drawer below the title</b> — the traditional spot that collapses on scroll`]
},
q4: {
  what: `The drawer search bar <b>stays visible even while scrolling</b> (<span class="pill">displayMode: .always</span>).`,
  when: `When the flow of the screen <b>needs search repeatedly</b> — where "finding" is the main usage pattern, as in Contacts, and re-searching must be possible at any point mid-scroll.`,
  why: `The default (collapsing) puts space first, but on search-heavy screens <b>"the cost of bringing it back" exceeds "the cost of the space."</b> This option lets the developer flip that trade-off according to the character of the screen.`,
  tip: `Always consumes vertical space permanently. Confirm with data that search really is that frequent before choosing it.`,
  ok: `① Screens that always need search, such as a dictionary or an address book ② Long lists where filtering searches are frequent`,
  ng: `① Always-on search on a short list of fewer than ten items — wasted space ② Pinning it with always and adding bottom search on top (two slots occupied)`,
  cap: [`The drawer search bar <b>pinned through scrolling</b> (.always)`]
},
q5: {
  what: `The search field in the toolbar's <b>dead center (principal)</b> — search takes over the title slot.`,
  when: `When search <b>is the reason the screen exists</b> — a search-only tab or screen, or a browser's address/search field: cases where "this screen = search."`,
  why: `Exactly the grammar of the principal slot ("the identity of the screen") — if search is the identity, search goes in the center. The same logic as Single Principal Item (1.1.5), applied to search.`,
  tip: `Putting an ordinary list's search here makes the screen read as "a search-only screen," which is too much. Only when search truly is the star.`,
  ok: `① A screen where "this screen = search," like web search ② Map search — when search, not a title, is the essence of the screen`,
  ng: `① Removing an ordinary list's title and centering search (losing orientation) ② Offering principal search and bottom search at once (duplication)`,
  cap: [`Search takes the <b>title slot (center)</b> — for when "this screen = search"`]
},
q6: {
  what: `The system search bar <b>integrated into one toolbar system</b> with the other items — combining slot reservation, separation and minimization.`,
  when: `Screens where search coexists with several actions but <b>search does not need to be large all the time</b>. The toolkit: <span class="pill">DefaultToolbarItem(.search)</span> (the slot), <span class="pill g">ToolbarSpacer</span> (separation), <span class="pill g">searchToolbarBehavior(.minimize)</span> (collapsed to a magnifier button normally, expanding on tap).`,
  why: `<b>The search version of the minimization principle</b>: offer the feature, but step back until asked. On a screen where search is a supporting role, a full-size search bar wastes space — folded to button size it yields room to other actions while staying one tap away. It does for the search bar what overflow does for buttons.`,
  tip: `.minimize does not "hide" search, it "folds" it — if a screen barely uses search, the right move is to drop searchable altogether.`,
  ok: `① A browser — search minimized, coexisting with tab and share buttons ② Files — a collapsed search alongside sort and view buttons`,
  ng: `① Keeping search around, even minimized, when it is barely used (searchable itself is unnecessary) ② Putting a similar icon (filter) next to the collapsed magnifier, causing confusion`,
  cap: [`Normally <b>folded into a magnifier button</b> — expands into a search bar on tap`]
},
x1: {
  what: `<span class="pill">lineLimit(n)</span> — <b>fixes the maximum number of lines</b> the text may take. Anything beyond is truncated.`,
  when: `Wherever <b>layout height must stay constant</b>, such as list cells and card previews. The two-line body preview in a mail list, or a two-line headline on a news card. Assumes "the full text lives on the detail screen."`,
  why: `SwiftUI Text defaults to <b>unlimited wrapping</b>, because not truncating content is the principle. But in a list, cells of varying height break the scanning rhythm and reduce how many items fit on screen → since <b>a list exists for scanning, not close reading</b>, the developer limits it explicitly in preview contexts.`,
  tip: `With large Dynamic Type, the same sentence takes more lines. When choosing a lineLimit, verify that the essential information survives at accessibility text sizes.`,
  ok: `① Standardizing feed body previews at lineLimit(3) ② Fixing list cell titles to one line to keep row height constant`,
  ng: `① Truncating essential information such as an address or an amount with no path to see the whole thing ② One-line limit plus scaling at large accessibility sizes, leaving the text effectively unreadable`,
  cap: [`<b>Exactly two lines</b> — cell heights stay constant`]
},
x2: {
  what: `<span class="pill">truncationMode(.head / .middle / .tail)</span> — chooses <b>which part folds into the …</b> when text is cut.`,
  when: `Decide by <b>where the information value sits</b> — sentences and titles front-load meaning, so <b>.tail</b> (the default); file paths and long names matter at both ends, so <b>.middle</b>; when the end is the conclusion, as in "arrived from …", use <b>.head</b>.`,
  why: `The default is .tail because natural-language sentences generally <b>front-load their information</b>, so preserving the beginning loses the least on average. But identifiers (paths, URLs, hashes) share a common prefix, so seeing only the front makes them <b>impossible to tell apart</b> — hence the modes are exposed.`,
  tip: `If a piece of text truncates often, question "is this width and line count right in the first place?" before picking a truncation mode. Truncation is a last-resort safeguard, not a layout technique.`,
  ok: `① .middle for file paths — both the start (location) and the end (file name) carry information ② Keeping the .tail default for email subjects — the front is what matters`,
  ng: `① .tail on an order number whose trailing digits are the discriminator — the part you need is cut ② .middle on people's names — awkward cuts like "Jo…son"`,
  cap: [`<b>Where the … goes</b> is the option — chosen by where the information value is`]
},
x3: {
  what: `<span class="pill">minimumScaleFactor(0.5)</span> (+ <span class="pill">lineLimit(1)</span>) — fits the space by <b>shrinking the type</b> instead of cutting it.`,
  when: `<b>Short values that only mean something in full</b> — timer digits, amounts, temperatures, button labels. Text whose information is destroyed by a cut like "12:34:5…".`,
  why: `Truncation and scaling are opposite answers to the same problem — <b>cut it if it still reads (sentences), shrink it if cutting kills the meaning (values and figures)</b>. The system leaves the choice to the developer because whether text is "a sentence" or "a value" is semantics, undecidable from code alone.`,
  tip: `If it only fits below a scale factor of 0.5, that is <b>a design problem</b>, not a scaling one — widen the space or shorten the notation itself (1,234,000 → 1.2M). Also watch for the side effect of the type looking mismatched against neighboring text on the same line.`,
  ok: `① Big numerals on a timer or gauge — one line regardless of length ② A safeguard for button labels whose length swings with localization`,
  ng: `① Applying it to body paragraphs so the type size differs on every screen ② Allowing excessive shrinking such as minimumScaleFactor(0.3) — legibility destroyed`,
  cap: [`<b>Shrink the type</b> instead of cutting — the whole value is preserved`]
},
x4: {
  what: `<span class="pill">lineLimit(2...4)</span> for a range and <span class="pill">lineLimit(3, reservesSpace: true)</span> — control not just the maximum but the <b>minimum line count and reserved space</b>.`,
  when: `When content length varies wildly but <b>cell and card heights must stay uniform</b>. In a grid mixing one-line and four-line reviews, reserving three lines even for short text keeps every card the same size.`,
  why: `A maximum alone (2.1.1) cannot prevent <b>"short content wrecking the layout"</b> — cards of differing heights in a grid break the visual alignment. This turns <b>the space the text occupies</b>, rather than the text itself, into a contract, separating content from layout.`,
  tip: `reservesSpace consumes empty space permanently. Use it only for grids and horizontally scrolling cards that genuinely need uniformity; in a vertical list a maximum is usually enough.`,
  ok: `① lineLimit(3, reservesSpace: true) to keep card heights uniform ② A review preview in the 2...4 range — it keeps a minimum shape even when short`,
  ng: `① Reserving three lines when the text is always one line — pure wasted space ② Setting a range but providing no "More" path to the overflowing content`,
  cap: [`Even short text <b>reserves the same height</b> — card alignment holds`]
},
x5: {
  what: `<span class="pill">textSelection(.enabled)</span> — lets read-only text be <b>long-pressed to select and copy</b>.`,
  when: `Text that is <b>worth taking away</b> — addresses, phone numbers, coupon and verification codes, error messages, quotations. If "would someone want to copy this?" is yes, turn it on.`,
  why: `It is off by default because most text in a UI is <b>a label (part of the machinery), not content (data)</b>. Once button names become selectable, they collide with long-press gestures (context menus and the like) and the whole screen starts behaving like a document. Selectability itself is the signal that "this is data."`,
  tip: `On iOS this copies <b>the entire text at once</b>, not a partial selection. It suits values used whole, like codes and addresses; if partial quoting of long prose is needed, consider a different UX (a share sheet, for example).`,
  ok: `① Enabling it on values people copy, like error codes and order numbers ② Enabling it on reference text such as terms or addresses`,
  ng: `① Allowing selection on button labels — tap and long-press collide ② Not enabling it on a tracking number, so users copy it out by hand from the screen`,
  cap: [`Long-press and <b>the whole thing is selected and copied</b> — the "this is data" signal`]
},
f1: {
  what: `<span class="pill">Text(measurement, format: .measurement(width: .wide))</span> — converts a <b>Measurement value</b> (length, mass, temperature) into locale-appropriate unit notation automatically.`,
  when: `Everywhere you show <b>a number with a unit</b> — distance, mass, temperature, speed: a workout distance of "5 km", weather at "23°C", a weight log. For an app shipping globally it is a requirement, not an option.`,
  why: `String assembly like <span class="pill a">"\\(value) km"</span> is <b>an internationalization bug that forces kilometers on users who think in miles</b>. Measurement + FormatStyle separates the value from its presentation, so the same data renders as "5 kilometers" / "3.1 miles" / "5킬로미터" depending on locale. Unit conversion, pluralization and symbol placement are the system's job, so the app only has to <b>own the value</b>.`,
  tip: `Pick density with width — <b>.wide</b> ("5 kilometers", inside a sentence), <b>.abbreviated</b> ("5 km", lists and labels), <b>.narrow</b> ("5km", tight spaces). Switching the simulator locale to en_US to confirm the mile conversion is the verification point.`,
  ok: `① Distance in a running app — km/mi swapped automatically by locale ② Weather temperature — °C/°F delegated to the system setting`,
  ng: `① Hardcoding the string "\\(value) km" — km even for users on miles ② Hand-rolling unit conversion and introducing rounding and notation errors`,
  cap: [`<b>One and the same value</b> — the locale decides the notation`]
},
f2: {
  what: `<span class="pill">PersonNameComponents</span> + <span class="pill">.name(style:)</span> — treat a person's name as <b>given/family components</b> and leave the display order to the system.`,
  when: `<b>Everywhere a person's name appears</b> — users, contacts, participants: full names, shortened names in lists, avatar initials.`,
  why: `Hardcoding "given family" order (John Appleseed) is <b>wrong in Korea, Japan, China and Hungary</b> (rendering 홍길동 as "길동 홍") — name order is a cultural rule, not data. Store components (givenName, familyName) and let the locale decide the presentation, and the same data comes out in the correct order in every culture.`,
  tip: `Use style to match the purpose — <b>.long</b> (with honorifics), <b>.medium</b> (the default full name), <b>.short</b> (a familiar form of address), <b>.abbreviated</b> (initials "JA" → ideal for avatars). If you currently store names as two strings, firstName/lastName, the migration to PersonNameComponents is where this starts.`,
  ok: `① Contact display — family-given in Korean, given-family in English, automatically ② Using the .abbreviated style for initial avatars`,
  ng: `① Hardcoding "\\(first) \\(last)" — East Asian names come out reversed ② Using the display string as a sort key — the family/given basis ends up scrambled`,
  cap: [`<b>Name order</b> is a cultural rule — never hardcode it`]
}

,
tb1: {
  what: `The <b>standard tab item</b>: an icon plus a one-word title. The selected tab is emphasized with the tint color.`,
  when: `<b>Nearly every tab.</b> It is the default and the right answer by the standards of clarity and accessibility. Depart from it only with a clear reason.`,
  why: `The icon is for fast scanning, the title for pinning down the meaning — an icon alone is ambiguous (is that heart a favorite or health?). The principle that <b>recognition is cheaper than recall</b>: give both channels and it reads without learning.`,
  tip: `Keep titles to a single noun (Home, Library, Settings). Verbs and sentence-like labels are the grammar of buttons, not tabs.`,
  ok: `① Home · Search · Library · Profile — one noun plus a standard SF Symbol ② Distinguishing selected from unselected with filled vs. outlined icons`,
  ng: `① A long label like "My Saved Items" — clipped or overlapping ② An abstract icon of unclear meaning paired with an unfamiliar coined term`,
  cap: [`Icon + <b>a one-word title</b> — the standard form of a tab item`]
},
tb2: {
  what: `A tab item made of <b>the icon alone</b>, with no title.`,
  when: `When every tab uses a <b>universally agreed icon</b> (home, search, profile) and minimalism is the app's identity. Occasionally chosen by immersive photo and media apps.`,
  why: `Dropping labels reduces visual noise but <b>shifts the cognitive cost onto the user</b>. The system exposes it as an option because the balance point differs by app character — the baseline recommendation is still title + icon.`,
  tip: `Even without an on-screen label, <b>accessibilityLabel is mandatory</b>. For VoiceOver users, that label is everything.`,
  ok: `① When the icons read universally, like play or search ② Limited use on a secondary bar where space is extremely tight`,
  ng: `① Expressing app-specific concepts ("Mood", "Feedback") with an icon alone ② Four similar-looking outline icons lined up unlabeled — indistinguishable`,
  cap: [`<b>Icon only</b> — the minimal form, allowed only when the meaning is universal`]
},
tb3: {
  what: `A <b>red numeric badge</b> at the item's top right (<span class="pill">.badge(3)</span>) — the count of unhandled items.`,
  when: `When <b>"how many" drives the decision</b> — unread messages, pending notifications: information where the number decides whether you go in.`,
  why: `A badge is an <b>interrupt device</b> that calls the user. Red plus a number is the OS-wide convention for "not yet handled," so the app has nothing to teach. Badge every tab and the interrupt value inflates — the notifications that actually matter get buried.`,
  tip: `<b>Remove</b> the badge when it reaches zero (never display "0"). An app whose badge does not clear after you check it loses trust.`,
  ok: `① The unread count on a Messages tab ② The number due today on a to-do tab — a count that goes down as you work`,
  ng: `① A permanent badge that never decreases (a marketing "1") — burning trust ② Showing a raw three-digit number instead of folding it to "99+"`,
  cap: [`A <b>numeric badge</b> on the item — the convention for unhandled counts`]
},
tb4: {
  what: `A <b>short text badge</b> instead of a number (<span class="pill">.badge("NEW")</span>) — a status notice.`,
  when: `When <b>the status, not a count, is the information</b> — "NEW", "LIVE": things that mean nothing when counted. Announcing a new-feature tab, marking a live broadcast.`,
  why: `It borrows the grammar of the numeric badge (an attention-grabbing red pill) while <b>extending the meaning to states</b>. Long text invades the tab layout, so the system is designed around short strings.`,
  tip: `Keep it to two to four characters. And <b>a "NEW" that is always there is no longer new</b> — remove it the moment the condition ends.`,
  ok: `① A temporary "NEW" on a newly added tab ② "LIVE" on a tab that is currently broadcasting`,
  ng: `① "NEW" stuck there for months — nobody believes it anymore ② A long badge like "SALE 50%" invading the tab label`,
  cap: [`A <b>short text badge</b> instead of a number — announcing a state`]
},
tc1: {
  what: `The <b>minimal structure of just two tabs</b> — two destinations sharing the whole bottom bar.`,
  when: `When the app's world <b>genuinely divides in two</b> — like "Listen Now / Library": an app with exactly two areas of clearly different character.`,
  why: `The tab bar is <b>expensive real estate</b> that occupies the bottom permanently — the fewer the items, the clearer each tab. That said, with only two, a segmented control may be enough. The system does not enforce a count because structure is a question about your domain.`,
  tip: `If usage between the two tabs skews 9:1, that is a signal to rethink the structure — the minor one may belong in a settings screen or a sheet.`,
  ok: `① A podcast-style app — the two worlds of listening and library ② A tool app — two equal axes such as work and history`,
  ng: `① Forcing one screen that a segmented control would handle into two tabs ② Promoting a 9:1 side feature to a tab (settings or a sheet is the right structure)`,
  cap: [`<b>Two tabs</b> — minimal structure, maximum clarity`]
},
tc2: {
  what: `<span class="pill">.tabBarMinimizeBehavior(.onScrollDown)</span> — the tab bar <b>folds down small</b> when you scroll down and returns when you scroll up.`,
  when: `Feed and reader screens where <b>immersion in the content matters</b>. Apps where "scroll down = reading, scroll up = back to navigating" holds true.`,
  why: `The Liquid Glass minimization principle applied to the tab bar — <b>a navigation device only needs to be large while you navigate</b>. It infers intent from scroll direction, and because it folds rather than disappears, the positional cue survives.`,
  tip: `In apps with frequent tab switching (messengers, for example) it is a nuisance. Enable it only on content-consumption screens.`,
  u27: `Apple has partly reversed course — in the iOS 27 betas the <b>scroll-to-minimize behavior has been removed from its own apps</b> such as Music and Podcasts, returning to an always-visible tab bar (acting on feedback that "making people spend an extra tap to bring it back is worse than a pretty animation"). The API remains, but for a new app, judge adopting minimize more conservatively.`,
  ok: `① An immersive news or article feed ② A vertically scrolling video feed — navigation is rare while consuming`,
  ng: `① Applying it to a messenger with frequent tab switching — every switch needs a restore ② Applying it to a short screen that barely scrolls — the motion is just noise`,
  cap: [`Scroll down and the tab bar <b>folds down small</b> — yielding room to content`]
},
tc3: {
  what: `The typical configuration inside the <b>standard range of three to five</b> — the balance point most apps land on.`,
  when: `<b>Most apps</b>, whose top-level areas resolve to three to five. A safe range you can adopt without agonizing.`,
  why: `The intersection of touch target size and cognitive load — past five, each target narrows below thumb accuracy, and too many top-level concepts make the structure itself unreadable. The principle is <b>not "everything as a tab" but pushing the less important down into screens inside a tab</b>.`,
  tip: `If the fourth or fifth tab is becoming "Other/More," that is a signal to redraw your information architecture.`,
  ok: `① The standard four: Home · Search · Library · Profile ② When each tab is a peer destination in the information architecture`,
  ng: `① Filling the leftover slot with a "More" junk drawer ② A promotion-only tab that is not a destination — advertising disguised as structure`,
  cap: [`<b>Three to five</b> is the standard — the balance between target size and cognitive load`]
},
tc4: {
  what: `<b>Six tabs</b>, past the standard range — the limit case showing how far the system will go.`,
  when: `An exceptional choice for genuinely large, feature-rich apps. This demo is less "do it this way" than <b>"here is what happens if you push this far."</b>`,
  why: `At iPhone width, six squeezes both targets and labels. The reason the declaration is still accepted: the same declaration <b>adapts into a sidebar on iPadOS</b>, so the system can handle per-device rearrangement.`,
  tip: `When six seems necessary, two of them are usually the same concept — merge first, add last.`,
  ok: `① Accepting the system's automatic compression when six is unavoidable in the architecture ② Six tabs in an iPad layout that has room to spare`,
  ng: `① Forcing six on iPhone — clipped labels and shrunken touch targets ② Transplanting the company org chart (a tab per department) straight into the tab structure`,
  cap: [`<b>Six</b> — overcrowded on iPhone, adapting into a sidebar on iPad`]
},
tv1: {
  what: `The default behavior: the tab bar <b>stays visible</b> no matter how deep you go.`,
  when: `<b>The default.</b> Most apps, where switching tabs must always be possible — shallow hierarchies of about list → detail.`,
  why: `The tab bar is <b>a permanent map</b> showing "where you are and where you can go" — its constant presence is itself the safeguard against disorientation. Even deep inside, the context "I am within this tab" holds.`,
  tip: `Because it is always visible, it competes for space with bottom toolbar actions. Be sparing with bottom actions on screens that have a tab bar.`,
  ok: `① Most browsing apps — jump between sections at any time ② Commerce — constant access to cart and search tabs while exploring`,
  ng: `① Keeping it even in a full-screen media viewer — breaking immersion ② Leaving tab switching open mid-checkout — risking loss of entered data`,
  cap: [`The tab bar <b>persists</b> into detail screens — acting as a permanent map`]
},
tv2: {
  what: `<b>Hiding</b> the tab bar on a pushed detail screen with <span class="pill">.toolbar(.hidden, for: .tabBar)</span>.`,
  when: `When the detail is <b>immersive</b> — a full-screen photo, video playback, a reading view. Or when switching tabs would break the flow, as on a compose screen.`,
  why: `In a list, navigating is the primary task; in a detail, consuming is — and <b>changing the chrome when the primary task changes</b> is content-first. The space the tab bar gives up returns to the content, and Back becomes the single exit.`,
  tip: `Check that hiding and re-showing causes no layout jump. Bottom UI that depends on the tab bar's height will break.`,
  ok: `① Immersive details such as full-screen photos or video playback ② Flows that must be completed, like checkout or signing`,
  ng: `① Hiding it on a shallow two-level settings screen — you only lose mobility ② Hiding it and re-implementing a lookalike tab bar at the bottom (duplicated implementation)`,
  cap: [`On a detail screen, the tab bar's space is <b>returned to the content</b>`]
}

,
ts1: {
  what: `Search placed as <b>one of the ordinary tabs</b> — a section on equal footing with the rest.`,
  when: `When search is a <b>major destination</b> on par with browsing — as in the App Store or media apps, where the search tab has its own content: recommendations, trending, and so on.`,
  why: `Tabs are top-level structure, so making search a tab is <b>a declaration that "search is one of our app's worlds."</b> For filter-style search that narrows a list it is overkill — that is what <span class="pill">.searchable</span> inside the screen is for.`,
  tip: `A search tab holding nothing but an empty field wastes the slot — fill it with "pre-search content" such as recommendations and recent searches.`,
  ok: `① The App Store — recommendations and charts inside the search tab ② A media app — trending and recent searches in the search tab`,
  ng: `① A search tab that is nothing but an empty field — a wasted top-level slot ② Promoting filter-style search to a tab (.searchable is the right structure)`,
  cap: [`Search as <b>one of the ordinary tabs</b> — a peer destination`]
},
ts2: {
  what: `<span class="pill">Tab(role: .search)</span> — the system recognizes the search tab and places it as <b>a glass capsule detached from the others</b> (on the right). New in iOS 26.`,
  when: `The <b>new standard</b> for a search tab on iOS 26. Declare the role and the system handles position, shape and transition behavior.`,
  why: `A tab is "moving to a place," but search is <b>"entering a mode"</b> — separating something of a different nature visually too (its own capsule) expresses it consistently across the OS. On tap the capsule morphs in place into a search field, so the mode changes without navigating.`,
  tip: `Declare the role and do not customize position or shape — depart from the system convention and you break the user's expectations.`,
  u27: `In iOS 27, press reports and betas confirm a course correction: Apple's own apps (Music, Podcasts, TV, News) are <b>folding the search tab back into the main tab row</b>. The detached capsule is being repositioned from "the new standard" to <b>"one option among several"</b> — adopt it only after asking more strictly whether search really is a separate mode (the question at the top of this section).`,
  ok: `① A streaming app treating search as a separate mode and adopting the detached capsule ② Declaring only the role and leaving position, shape and transition to the system`,
  ng: `① Customizing the detached capsule's position or shape — departing from the system convention ② Imitating the search capsule slot to host a compose button (misusing the slot)`,
  cap: [`search role — search placed as a <b>detached capsule (right)</b>`]
},
ts3: {
  what: `search role + <span class="pill">tabBarMinimizeBehavior</span> — on scroll, <b>the tab bar folds while the search capsule stays, shrunken</b>.`,
  when: `Apps that need both content immersion (a feed) and <b>constant access to search</b> — usage patterns where "let me find that thing" comes up often mid-browse.`,
  why: `A division of roles between folding (tab bar) and staying (search) — navigation is needed less while consuming, whereas <b>search is often triggered by consuming</b>. The two APIs are designed orthogonally, so the combination falls out naturally.`,
  tip: `Check the fold/unfold animation on a real device as scroll direction changes. It is a poor fit for screens with little scrolling.`,
  ok: `① A content app that needs both feed immersion and always-available search ② Commerce, where you browse a long catalog and search constantly`,
  ng: `① Applying the combination to a barely-scrolling screen — the folding and restoring is just noise ② Keeping the capsule resident when search is rarely used — unnecessary permanent UI`,
  cap: [`The tab bar folds, but <b>search stays one tap away</b>`]
},
ts4: {
  h3: `Prominent Role <span style="font-size:13px;color:var(--amber)">— new in iOS 27 (WWDC26)</span>`,
  what: `<span class="pill">Tab(role: .prominent)</span> — <b>opens the trailing detached capsule, previously search-only, to ordinary tabs</b>. The system applies extra visual emphasis to that tab.`,
  when: `When the app has <b>one core destination</b> worth emphasizing — cart, tickets, trips, order history: <b>"a place you go often."</b> The iOS 27 extension that lets a non-search tab live in the detached capsule.`,
  why: `Once iOS 26 made the detached capsule search-only and "a slot that looks like a button," developers spread the pattern of misusing it for compose and upload buttons → Apple absorbed that demand by opening <b>an official path called "an emphasized destination."</b> But prominent <b>is still a tab</b> — the meaning (going to a place) is unchanged; only the appearance is emphasized.`,
  tip: `<b>Do not put action buttons (compose, upload, scan, create) here.</b> It is not a stand-in for a FAB — if you cannot answer yes to "does tapping it take me somewhere?", it is an action, not a tab, and actions belong in the toolbar.`,
  ok: `① Emphasizing the <b>Cart</b> tab in commerce — a place you go often ② A travel app's <b>My Trips</b> tab — highlighting one core destination`,
  ng: `① Disguising a <b>compose or upload</b> button as a prominent tab — an action is not a tab ② A fake tab that only presents a sheet instead of navigating — it cannot answer "where does this go?"`,
  cap: [`<b>A non-search tab</b> (a cart, say) in the detached capsule — but it must be a "place"`]
},
ta1: {
  what: `The base configuration where <b>an accessory view lives above</b> three tabs — it persists as you switch tabs.`,
  when: `<b>In-progress state</b> that must survive whichever tab you are on — music playback, an active call, an upload, a timer.`,
  why: `State that spans tabs is owned by <b>the app as a whole</b>, not by any one screen — which is why it attaches to the tab bar layer rather than to tab content. It standardizes, as a system API, the Music mini-player pattern everyone used to build by hand.`,
  tip: `One accessory, one line tall. Putting a banner or an ad here violates the slot's grammar.`,
  ok: `① The Music mini player ② An "on a call" or "recording" status bar — persisting across every tab`,
  ng: `① An ad banner in the accessory slot — violating the slot's grammar ② A complex two-line control panel — violating the one-line-height principle`,
  cap: [`Global state (a mini player, say) living on the <b>layer above</b> the tab bar`]
},
ta2: {
  what: `Accessory + tab bar minimization — on scroll the tab bar folds and <b>the accessory settles down into its place</b> (the inline placement).`,
  when: `When content immersion and persistent global state are needed <b>at the same time</b> — a Music-style app where the playback controls must remain while you scroll lyrics or a list.`,
  why: `The key is that when things fold, the accessory does not vanish but is <b>promoted into the tab bar's slot</b> — the system handles the priority inversion "state &gt; navigation" automatically, so you never build two separate layouts.`,
  tip: `The accessory view must read at both sizes, expanded and inline — branch on the <span class="pill">tabViewBottomAccessoryPlacement</span> environment value.`,
  ok: `① Keeping playback controls while scrolling lyrics ② Keeping the playback bar while browsing an episode list`,
  ng: `① Leaving the expanded layout with no inline handling — it clips once folded ② Putting tab-switching buttons in the accessory — confusing navigation with state`,
  cap: [`When the tab bar folds, the accessory <b>settles into its place</b> (inline)`]
},
ta3: {
  what: `Tabs + search role + accessory + minimization — <b>the full bottom-system configuration</b>.`,
  when: `Large media and content apps that must fit <b>navigation (tabs), search and global state (accessory)</b> into the bottom.`,
  why: `Three systems sharing one region need conventions of their own — <b>tabs = the group on the left, search = the detached capsule on the right, accessory = the layer above</b>. All of it is under system control, so combining them causes no conflict and the app never computes coordinates.`,
  tip: `The full set makes the bottom heavy. If the content feels squeezed, turn on minimization so it steps back during consumption.`,
  ok: `① A full streaming configuration — tabs + search capsule + mini player + minimize ② The same configuration in an audiobook app — each element doing only its own job`,
  ng: `① Turning everything on with no hierarchy design — an overcrowded bottom ② Forcing the full set without verifying overlap and clipping on small (SE-class) screens`,
  cap: [`<b>Tabs + search + accessory</b> — the full bottom-system configuration`]
}

,
sh1: {
  what: `<span class="pill">.presentationDetents([.large])</span> — the <b>default sheet</b>, covering nearly the whole screen. The screen behind recedes slightly and stays visible.`,
  when: `<b>Self-contained flows</b> — composing a new item, editing a profile: work that does not need to reference the background context. The default and most common form of sheet.`,
  why: `A sheet is the device for <b>"a temporary context switch"</b> — large is effectively a new screen, but the stack metaphor of the background peeking through preserves the feeling that "when this is done, I return to where I was." That metaphor is what distinguishes it from push, which is a permanent move.`,
  tip: `If the sheet holds work in progress, watch out for loss from swipe-to-dismiss — consider <span class="pill">interactiveDismissDisabled</span> plus a confirmation dialog.`,
  ok: `① An input-heavy form sheet such as creating a new event ② An editing screen you scroll through several sections of`,
  ng: `① A full-height sheet for a two-item choice ② Covering everything when the task requires referring to the screen behind`,
  cap: [`The <b>default (large) sheet</b> covering nearly the screen — the background peeks through`]
},
sh2: {
  what: `<span class="pill">.presentationDetents([.medium])</span> — a sheet that rests at <b>half the screen height</b>.`,
  when: `Supporting work done <b>while watching the background</b> — search results over a map, a filter panel, share options. Tasks where you alternate between the original and the sheet.`,
  why: `Half height is the metaphor of <b>"a conversation with the original"</b> — by splitting the screen, the shape itself says the sheet is about the content behind it. It standardizes, as a system detent, the pattern the Maps app invented.`,
  tip: `When the keyboard appears on a medium sheet, the system pushes it up to large — if the sheet is centered on input, large is more natural from the start.`,
  ok: `① Place information over a map — checked while looking at the map behind ② Options and share sheets, where half height is enough`,
  ng: `① Cramming a long form into medium, producing double scrolling inside the sheet ② Medium with the background dimmed — erasing the reason for half height`,
  cap: [`<b>Half height (medium)</b> — supporting work done against the background`]
},
sh3: {
  what: `<span class="pill">.height(250)</span> · <span class="pill">.fraction(0.3)</span> — a detent at a <b>custom height</b> rather than the two system steps.`,
  when: `When the content has <b>a height of its own</b> — an action panel of a few buttons, playback controls: small UI for which even medium is too much.`,
  why: `Sheet height should be decided by the content — putting small content in medium creates <b>leftover whitespace that reads as "is there something more?"</b> But arbitrary heights hurt consistency, so this is the compromise: custom values inside the detent system.`,
  tip: `<span class="pill">.fraction</span> or content-based sizing is safer than fixed points — always check that nothing clips at large Dynamic Type sizes.`,
  ok: `① A playback queue panel at .height(250) ② A filter panel at .fraction(0.3) — the minimum height its content needs`,
  ng: `① A fixed pixel height never verified across devices — overflowing on small screens ② Obsessing over pixel tweaks when the two system steps would do`,
  cap: [`A custom detent matched to the <b>content's own height</b>`]
},
sh4: {
  what: `<span class="pill">[.medium, .large]</span> — declare <b>multiple detents</b> and let the user drag between the steps.`,
  when: `Content that needs both <b>skim and focus</b> modes — map search results (glance at half, drag up for the full list), detail panels.`,
  why: `"How much do I want to see right now?" is <b>the user's intent</b>, which the system cannot judge — so the choice of height is handed to them. The drag gesture is the expression of that intent, and the grabber is the affordance saying "there are more steps."`,
  tip: `Multiple detents with no visible grabber cannot be discovered — make it explicit with <span class="pill">presentationDragIndicator(.visible)</span>.`,
  ok: `① Map search results — skim at medium, drag up to large for detail ② The step from preview to expanded editing`,
  ng: `① Hiding the visual cue (the grabber) that it expands — undiscoverable ② A layout that changes drastically at each step — continuity lost`,
  cap: [`Stepping between <b>medium ↔ large</b> — the grabber signals "there is more"`]
},
sh5: {
  what: `<span class="pill">.presentationBackgroundInteraction(.enabled(upThrough: .medium))</span> — <b>the content behind stays interactive</b> while the sheet is up. No dimming.`,
  when: `When the sheet acts as a <b>tool palette</b> — keeping a results sheet up while you keep moving the map, using a formatting panel while you scroll the document.`,
  why: `The essence of a modal is "demand a response and block everything else" — but a tool panel is not a response, it is <b>parallel work</b>. This borrows only the sheet's shape (a bottom panel) and removes the modality. The absence of dimming is the visual signal that "you may touch what is behind."`,
  tip: `Without dimming, users easily forget the sheet is there — provide an explicit close button and check that the area it covers holds no essential content.`,
  ok: `① Keeping a place sheet up while you manipulate the map ② Adjusting an equalizer while still controlling the playback screen behind`,
  ng: `① A checkout sheet that requires commitment made nonmodal — background interaction leads to inconsistent state ② Dimming the background even though it is interactive, making it look modal (contradictory signals)`,
  cap: [`<b>No dimming</b> — work in parallel with the content behind the sheet`]
},
fc1: {
  what: `<span class="pill">.fullScreenCover</span> — covers <b>the entire screen</b> and cannot be dismissed by swiping down.`,
  when: `<b>Flows that need completion or an explicit cancel</b> — onboarding, sign-in, camera and full-screen media, a workout session: immersive screens that must not break from an accidental exit.`,
  why: `Unlike a sheet, nothing shows behind and there is no gesture dismissal — a strong modality that says <b>"finish this task, or leave explicitly."</b> The system separates the light sheet and the heavy cover into distinct APIs precisely because that difference in weight is a matter of user expectation.`,
  tip: `Since swiping does nothing, <b>the Done/Cancel buttons are the only exit</b> — omit a way to close and the user is trapped. Always verify it.`,
  ok: `① Flows that must not be abandoned before completion, like onboarding and sign-in ② Full video playback — the whole screen is the content`,
  ng: `① Covering the whole screen for a simple confirmation — overkill ② A cover with no close button — no swipe either, so there is no way out`,
  cap: [`A strong modal covering <b>the whole screen</b> — the only exit is an explicit button`]
},
tr1: {
  what: `The <b>default transition</b>, rising from the bottom — the default for every sheet.`,
  when: `<b>Most sheets.</b> When the sheet's content does not correspond to a particular element on screen, as with a compose screen opened from a "+" button.`,
  why: `Rising from the bottom is the spatial metaphor of <b>"a temporary layer stacking on top"</b> — identical across the OS, so users instantly predict "pull it down and it closes." That predictability is the value of this transition.`,
  tip: `Before agonizing over a custom transition — if the origin carries no meaning, standard as-is is usually the right answer.`,
  u27: `<span class="pill">.navigationTransition(.crossFade)</span> was added — a cross-fade transition usable <b>without designating a source view</b>, unlike zoom. It is the middle option for screens where "the origin is meaningless but standard's slide feels like too much."`,
  ok: `① A compose sheet opened from a "+" button ② An edit form opened from Settings — a sheet with no meaningful origin`,
  ng: `① Standard for a detail opened by tapping a card — throwing away the origin information (zoom is the answer) ② Varying the custom slide direction sheet by sheet — destroying predictability`,
  cap: [`The <b>standard transition</b> rising from the bottom — the same wherever it opens`]
},
tr2: {
  what: `<span class="pill">.navigationTransition(.zoom(sourceID:in:))</span> — the sheet <b>expands out of the element you tapped</b>.`,
  when: `When the sheet's content is <b>an expansion of the tapped element</b> — tap a card and that card's detail sheet opens.`,
  why: `A device that <b>proves through motion that what you pressed and what opened are the same thing</b> — spatial continuity is preserved, so nothing has to explain "where this came from." Standard discards the origin, so when the origin matters, zoom is the answer.`,
  tip: `A mismatch between sourceID and namespace falls back silently to standard — verify on a real device that the expansion starts from the right place. It is a poor fit for sheets with no origin (a compose button).`,
  ok: `① Tap a card → it expands into that card's detail sheet ② Tap a thumbnail → a preview sheet`,
  ng: `① Zoom on a compose button whose origin is meaningless ② Leaving a sourceID/namespace mismatch in place — shipping while silently falling back to standard`,
  cap: [`The tapped card <b>expands into the sheet</b> (zoom) — spatial continuity`]
},
tr3: {
  what: `The zoom transition <b>applied to a full screen cover</b> — a thumbnail expands to fill the screen.`,
  when: `When a small element expands into content that fills the screen — <b>a photo or video thumbnail → a full-screen viewer</b>.`,
  why: `The pattern the Photos app standardized — it opens by expanding and <b>shrinks back to its original place on close</b>, so the spatial model holds for the whole round trip. That continuity is also why the pull-down-to-close gesture feels natural even in full screen when you use zoom.`,
  tip: `Check the behavior when the destination of the closing shrink (the original cell) has scrolled off screen — a shrink with nowhere to go looks wrong.`,
  ok: `① A photo thumbnail → the full-screen viewer ② A map card → the full map screen`,
  ng: `① Full-screen zoom from a text row that has no visual counterpart ② A custom implementation that does not return to the original position on close — the spatial metaphor collapses`,
  cap: [`The element <b>expands to fill the screen</b> — the photo viewer pattern`]
}

,
va1: {
  what: `<span class="pill">.safeAreaBar(edge: .top)</span> — places a custom view in the <b>top safe area</b>. Scrolling content automatically starts below it.`,
  when: `<b>Persistent top UI</b> that a system nav bar cannot provide — a row of filter chips, a sync status banner, a custom header: things that must always float above the content.`,
  why: `overlay <b>covers</b> content, and safeAreaInset only pushes it aside with no edge effects — safeAreaBar gives you inset plus scroll edge effects, <b>opening the entire infrastructure of a system bar to a custom view</b>. Custom UI has to behave with the same grammar as the system for the screen to read as one system.`,
  tip: `Check that the first piece of content is not hidden behind the bar (automatic inset), and check legibility as content passes beneath the bar while scrolling.`,
  ok: `① A row of filter chips as a top bar — content starts below it automatically ② A sync status or offline banner`,
  ng: `① Stacking it with a ZStack instead of safeAreaBar, hiding the first line of content ② A top bar so tall it eats the content area`,
  cap: [`A custom bar in the <b>top safe area</b> — content is pushed down automatically`]
},
va2: {
  what: `A custom header configuration with <b>title text</b> inside the top safe area bar.`,
  when: `When a screen that does not use the system navigation bar needs <b>a header of its own</b> — apps with strong brand design, home screens with unusual layouts.`,
  why: `Abandoning the system nav bar used to mean implementing title placement, insets and edge effects yourself — safeAreaBar is the compromise where <b>the system supplies the infrastructure (inset + effects) and the app supplies only the content</b>. The middle ground between fully custom and system behavior.`,
  tip: `The nav bar's free features (title collapse on scroll, Dynamic Type handling) do not come along — verify yourself that the header holds up at large text sizes.`,
  ok: `① Showing a title in a custom layout that cannot use the nav bar ② A home screen that needs a brand header`,
  ng: `① A system nav bar and a custom title bar at once — a double header ② A custom header that ignores Dynamic Type — breaking at large text sizes`,
  cap: [`A <b>title</b> inside the top bar — a custom header with no system nav bar`]
},
va3: {
  what: `<span class="pill">.safeAreaBar(edge: .bottom)</span> — a custom bar in the <b>bottom safe area</b>. The end of the content is inset above the bar automatically.`,
  when: `<b>Custom bottom UI</b> that is neither a tab bar nor a toolbar — playback controls, a CTA button strip, an input accessory: bottom devices specific to that screen.`,
  why: `The bottom is <b>dangerous territory that overlaps the home indicator</b> — leaving the safe area math to the system removes per-device branching (indicator present or not, its height). It also aligns with reachability, keeping frequently used controls near the thumb.`,
  tip: `Check where the bar goes when the keyboard appears — a bar used together with input should ride above the keyboard to feel right.`,
  ok: `① A playback control bar ② A cart total + checkout button bar — the content end is inset automatically`,
  ng: `① Adding manual padding on top because you do not trust the automatic inset — doubled spacing ② A custom placement that intrudes into the home indicator area`,
  cap: [`A custom bar in the <b>bottom safe area</b> — dodging the home indicator is the system's job`]
},
va4: {
  what: `A custom bottom bar + a <b>hard edge effect</b> + system toolbar items coexisting.`,
  when: `Structural screens (above tables or input forms) where a custom bar and system toolbar items share the bottom and the <b>boundary with content must be crisp</b>.`,
  why: `The key point is that <b>a custom bar follows the same edge-effect grammar as a system bar</b> — scrollEdgeEffectStyle applies to safeAreaBar too, so the system toolbar and the custom bar read as one bottom system. The criterion for choosing hard is the same as 1.3.2: clarity over atmosphere.`,
  tip: `Toolbar items plus a custom bar make the bottom two layers deep, which is heavy — first consider whether they can merge into one.`,
  ok: `① An input field (hard for a clear boundary) coexisting with system toolbar buttons ② A checkout bar + a help button — custom and system dividing the roles`,
  ng: `① Keeping soft above an input field where the boundary matters — the starting point is vague ② Leaving the custom bar and system items overlapping (z-order) unresolved`,
  cap: [`A custom bottom bar + toolbar items — the boundary stated with a <b>hard divider</b>`]
},
va5: {
  what: `Safe area bars at the <b>top and bottom simultaneously</b> + soft effects + toolbar items — the full vertical configuration.`,
  when: `Dashboard and player screens where filters/status at the top and controls at the bottom must <b>both stay resident</b>.`,
  why: `Top and bottom must <b>use the same effect (soft)</b> for the content to read as "one surface passing between two panes of glass" — soft on top with hard at the bottom breaks the screen's material metaphor. Automatic insets at both ends, so content is never hidden at the start or end of the scroll, are also this API's job.`,
  tip: `A top bar plus a bottom bar plus a toolbar shrinks the content area fast — check the actual visible area on a small device.`,
  ok: `① A commerce list with a filter bar on top and an action bar below ② A status banner on top and a playback bar below — roles split by direction`,
  ng: `① Top and bottom bars together occupying 40% of the screen — the content is crushed ② The two bars using different materials and edge effects — soft/hard mixed with no rule`,
  cap: [`<b>Top and bottom together</b> — both unified with a soft fade`]
},
ha1: {
  what: `<span class="pill">.safeAreaBar(edge: .leading, alignment: .top)</span> + a material background — a vertical bar at the <b>top of the leading edge</b>.`,
  when: `When landscape or iPad needs a <b>vertical tool strip</b> — a drawing app's tool palette, a vertical tab strip, page tools in a document viewer.`,
  why: `A design that <b>generalizes the same API by changing only the direction</b> as the vertical bars — you never compute the horizontal safe area (the landscape notch) yourself. The material background is the legibility device for content brushing past the side, playing the same role as a top bar's edge effect.`,
  tip: `leading becomes <b>the right side</b> in RTL locales — if the tool genuinely needs to be on the physical left (accommodating a left-handed grip, say), re-check your intent.`,
  ok: `① A vertical tool palette in an iPad drawing app ② A left tool bar in video editing — devices with generous horizontal space`,
  ng: `① A vertical bar at iPhone width — eating the content's width ② An opaque solid color instead of a material — the flow of content behind is cut off abruptly`,
  cap: [`<b>Leading edge, top-aligned</b> — a vertical tool palette`]
},
ha2: {
  what: `<span class="pill">.safeAreaBar(edge: .trailing, alignment: .center)</span> — placed at <b>the vertical center of the trailing edge</b>.`,
  when: `Tall gesture controls — <b>zoom sliders, index bars, timeline scrubbers</b>: things you operate by sliding up and down.`,
  why: `The rationale for center alignment is <b>the arc of the thumb</b> — with a right-handed grip, the middle of the right edge is the natural place for a vertical slide gesture. Alignment options exist because a vertical bar's purpose differs at the top (choosing tools) and at the center (continuous gestures) — position distinguishes purpose.`,
  tip: `The trailing edge is also home to the scroll indicator — when laying this over a scroll view, check that they do not interfere.`,
  ok: `① A Contacts-style A–Z scroll index bar ② The zoom and current-location button cluster on the right of a map`,
  ng: `① Putting a key button where the right thumb covers it ② Using leading and trailing bars at once — eating into both sides`,
  cap: [`<b>Trailing edge, center-aligned</b> — a vertical control matched to the thumb's arc`]
},
m1: {
  what: `<span class="pill">.ultraThinMaterial</span> through <span class="pill">.thickMaterial</span> — <b>translucent layers of different thickness</b> that reflect the background behind them. They adapt automatically to a light background, a photo, or dark mode.`,
  when: `Anywhere a <b>floating layer</b> above content (a bar, card or panel) needs a background. There is one criterion for thickness — <b>the busier the content passing behind, the thicker</b> (the same legibility logic as 1.3.3).`,
  why: `A fixed color background looks like a "sticker" cut off from its surroundings — a material reflects what is behind and thereby expresses, as form, <b>the depth relationship "this layer floats above the content."</b> The system compensates automatically for light/dark and background brightness, so contrast holds without you computing a color per background — which is why a material is a "material," not a "color."`,
  tip: `Do not customize a material by layering color on it — <b>choose by thickness alone</b>. The text and icons on top of it are only finished when paired with the next topic (vibrancy).`,
  ok: `① .thinMaterial behind controls over a photo — the background shows through but the plane holds ② Delegating light/dark adaptation to the system instead of hardcoding colors`,
  ng: `① Hardcoding an rgba translucent color eyeballed from a screenshot — breaking on other backgrounds and in dark mode ② Stacking a material on top of another material — a murky, muddy overlap`,
  cap: [`<b>Same material, different thickness</b> — the busier the background, the thicker`]
},
vb1: {
  what: `The effect where text and symbols on top of a material are <b>rendered by blending in the background color</b> — semantic styles such as <span class="pill">.foregroundStyle(.secondary)</span> automatically become vibrant on a material.`,
  when: `<b>All text and icons</b> that sit on a material background — especially secondary and tertiary information: labels inside a glass bar, captions on a card.`,
  why: `An opaque fixed gray on a material <b>detaches from the background and turns murky</b> — vibrancy mixes in the color behind to achieve both the integrated "etched into the glass" feel and readable contrast. The primary/secondary/tertiary hierarchy is tied to vibrancy strength: the text version of the system philosophy of distinguishing information <b>by hierarchy rather than by color</b>.`,
  tip: `On a material, use <b>semantic styles (.primary/.secondary)</b> instead of custom fixed colors — vibrancy is applied automatically. The moment you use a fixed hex, you lose the effect entirely.`,
  ok: `① .secondary for supporting text on a material — automatically in harmony with the background ② Semantic styles on SF Symbols — remaining legible on any background`,
  ng: `① A fixed gray hex on a material — it never mixes with the background and looks murky and dead ② Making long body paragraphs vibrant too — increasing reading fatigue`,
  cap: [`Text on a material — <b>vibrancy draws in the background color</b> for contrast and integration at once`]
},
mn1: {
  what: `<span class="pill">Menu</span> — a list of actions that opens when a button is tapped. It composes icons, sections (<span class="pill">Divider</span>), submenus, <span class="pill">role(.destructive)</span>, and even embedded Toggles and Pickers.`,
  when: `When you need to <b>fold several related actions into one control</b> — a More (⋯) button, sort and filter options, per-item actions. The middle ground: too many to line up as buttons, too light to warrant a sheet. What toolbar overflow (1.1.7) generates automatically is this same menu.`,
  why: `The value of a menu is that <b>it requires no learning</b>, because the layout conventions are identical across the system — frequently used items sit near the button (above or below, depending on which way it opens), related items are grouped into sections, and destructive actions are separated by a Divider and colored red. Icons are included because they <b>scan faster than text</b> — a menu is UI you skim, not read.`,
  tip: `Keep submenus to one level — from two levels down they become undiscoverable. More than eight items is not a menu problem but <b>a structure problem</b>: split into sections, or promote some of it to a sheet or a screen.`,
  ok: `① A ⋯ menu — related actions grouped into sections, with <b>Delete separated at the bottom and in red</b> ② A sort criterion as a Picker, with a checkmark on the current value`,
  ng: `① Delete mixed in among the ordinary items — an accident waiting to happen ② Three levels of nested submenus — the user gets lost`,
  cap: [`An <b>action list</b> opened from a ⋯ button — sections, submenus (›), destructive actions separated and red`]
}

,
p1: {
  h3: `Content-First · Minimization — the UI steps back for the content`,
  what: `Chrome (titles, bars, buttons) is a means of serving the content, not the star. <b>The moment it is not in use, it should fold away or disappear.</b>`,
  crit: `<b>"Does this UI element contribute to the user's task at this very moment?"</b> If there are moments when it does not, then in those moments shrinking, folding or hiding should be the default.`,
  ok: `① <b>The Large title collapsing on scroll</b> (1.2.1) — on arrival, orientation contributes to the task, so it is big; once reading starts its contribution ends, so it folds into inline and hands the space back to the content. A behavior that re-asks "does this contribute now?" at every moment ② <b>Automatic overflow folding</b> (1.1.7) and <b>Menu</b> (7.1.1) — rarely used actions are unlikely to contribute to the current task, so they are folded away. Feature completeness is preserved while screen occupancy stays proportional to contribution ③ <b>searchToolbarBehavior(.minimize)</b> (1.4.6) — on a screen where search is a supporting role, it folds to the size of a magnifier button: still one tap away, but minimal footprint the rest of the time.`,
  ng: `① <b>Adding a bottom bar to a screen with a single action</b> (violating 1.1.1) — the whole bottom bar permanently occupies vertical space while only one button contributes. A violation of the criterion: "occupying the screen even in moments when it contributes nothing" ② <b>Drawer <code>.always</code> on a low-frequency search screen</b> (violating 1.4.4) — a search bar that contributes to the task in almost no moment consumes a full row permanently ③ <b>Filling leading, principal, trailing and bottom all at once</b> (violating 1.1.9) — the exact opposite of the criterion: "there is a slot, so fill it."`
},
p2: {
  h3: `Reachability — the more frequent, the closer to the thumb`,
  what: `On a large display the top is hard to reach one-handed. The principle that <b>frequency of use determines vertical placement</b>.`,
  crit: `<b>"Is it pressed often and repeatedly?"</b> If so, the bottom (the thumb's home ground). If it is an occasional decisive action (Done, Save), the top. Frequency and height must be inversely proportional.`,
  ok: `① <b>Mail's "New Message" in the bottom bar</b> (1.1.4) — the most repeated action in a mailbox, so the criterion puts it at the bottom. That is exactly where the iOS Mail app places it ② <b>iOS 26 moving search to the bottom</b> (1.4.1) — a high-frequency feature had been sitting in the hardest place to reach. A case of the system itself correcting for the frequency-to-height rule. On iPad it is top trailing, for a two-handed grip — the same criterion applied to that device's ergonomics.`,
  ng: `① <b>A one-shot "Done" button in the bottom bar</b> — Done is a low-frequency decisive action pressed once per screen, so the criterion puts it at top trailing. At the bottom it wastes the high-frequency slot and sits next to the tab bar (navigation), inviting role confusion (violating the Tip in 1.1.4) ② <b>Putting the most-used action in a top corner and leaving the bottom empty</b> — the equivalent of a camera app's shutter at top trailing. The highest-frequency control sits in the lowest-reachability position, forcing a grip change every time it is used one-handed.`
},
p3: {
  h3: `The grammar of position &amp; grouping — the slot and the capsule are themselves meaning`,
  what: `leading = navigation · principal = identity · trailing = commitment · bottom = frequency. And <b>the same glass capsule = one set</b>. Position and grouping are the language.`,
  crit: `<b>"Does this control's role match the grammar of its slot? Are the things bound into one capsule really one set?"</b> Keeping the grammar is what lets users predict where a button will be in an app they are seeing for the first time.`,
  ok: `① <b>A "Map/List" segmented control in principal</b> (1.1.5) — the value of this control changes the entire content of the screen, matching principal's grammar of "the identity of the screen" exactly ② <b>Splitting the tool cluster (leading) from the Done button (trailing)</b> (1.1.2) — view switching, sorting and filtering in one capsule (one set = tools), Done in its own single capsule (a decision). The gap between the capsules carries the information "different jobs" (1.1.3).`,
  ng: `① <b>A plain Share button in principal</b> (violating 1.1.5) — sharing is an additional action, not the identity of the screen. Put in the strongest slot in the hierarchy, it also removes the title, leaving nothing to say what the screen is ② <b>Dumping unrelated features into one capsule</b> (violating 1.1.3) — bind Sort, Share, Settings and Delete into one glass capsule and users read them as "one set." The grouping becomes false information and raises cognitive load ③ <b>Buttons and text fields in the Custom Large Title slot</b> (violating 1.2.6) — the title slot's grammar is "the identity of the screen." Putting interactive controls there breaks that grammar.`
},
p4: {
  h3: `Legibility &gt; aesthetics — when transparency and readability collide, readability wins`,
  what: `The transparency of Liquid Glass is aesthetics; controls being readable is function. <b>In a collision, the priority is always legibility and accessibility.</b>`,
  crit: `<b>"Is it still readable and tappable over the worst background (photos, high-contrast graphics) and under accessibility settings (large text, reduced transparency)?"</b> The verification standard is the worst condition, not the best one.`,
  ok: `① <b>Hard + thick material over photos and video</b> (1.3.3) — when translucent glass loses contrast over busy backgrounds, give up the transparency (aesthetics) and secure legibility with an opaque background. The official escape hatch for "pretty but unreadable" ② <b>Overflow guaranteeing the minimum touch target</b> (1.1.7) — shrinking buttons indefinitely to fit more items would take them below fingertip size, so the system folds them automatically and upholds the "can it be tapped?" criterion.`,
  ng: `① <b>Setting the scroll edge effect to hidden on a photo feed</b> (violating 1.3.4) — turn it off after checking a single bright condition and the controls vanish the moment a white photo passes behind the bar. A case of skipping the "verify against the worst background" criterion ② <b>lineLimit(1) never checked at large accessibility text sizes</b> (violating 2.1.1) — it looks fine at the default size, but at maximum Dynamic Type the essential information is cut down to its first word ③ <b>An opaque background color on a custom view over a glass toolbar</b> (violating 1.1.8) — laying an arbitrary background over glass whose contrast the system manages breaks the material hierarchy and makes contrast unpredictable in dark mode and with reduced transparency.`
}

,
p5: {
  h3: `Space is a contract, text is variable — semantics decide the treatment`,
  what: `Space is finite while text length is unpredictable. Which to use — truncation, scaling or reservation — is decided by <b>whether that text is "a sentence" or "a value."</b>`,
  crit: `<b>"Does it still make sense when cut?"</b> If yes, cut it (a sentence → truncation); if cutting kills the meaning, shrink it (a value → scale); if the goal is layout uniformity, reserve the space. And cutting and shrinking are <b>safeguards, not layout techniques.</b>`,
  ok: `① <b>The two-line body preview in a mail list</b> (2.1.1) — the body is a sentence, so the front still carries the meaning when cut, and the detail screen holds the full text. The textbook case of fixing height as a contract to match the list's purpose (scanning) ② <b>minimumScaleFactor on timers and amounts</b> (2.1.3) — "12:34:56" is a "value" whose information is destroyed the moment it is cut, so shrink instead of cutting ③ <b>.middle truncation on file paths</b> (2.1.2) — paths share a common prefix, so seeing only the front makes them indistinguishable. The information value is at both ends, so folding the middle is the choice that fits the criterion.`,
  ng: `① <b>Cutting amounts and timers with the default .tail</b> (violating 2.1.3) — "₩1,234,0…" does not still make sense; it displays a wrong value. Applying the sentence solution to text that answers no to "does it still make sense when cut?" ② <b>Cramming things in down to a scale factor of 0.3</b> (violating 2.1.3) — if it only fits at less than half size, that is a design problem, not a scaling one. Widening the space or shortening the notation (1,234,000 → 1.2M) is the answer ③ <b>reservesSpace across an entire vertical list</b> (violating 2.1.4) — the point of reserving space is uniformity in grids and horizontal cards. In a vertical list that does not need uniformity, every short cell just burns empty space permanently.`
},
p6: {
  h3: `Separate data from its presentation — the app owns the value, the locale owns the notation`,
  what: `Notation rules for units, names and dates differ by culture. <b>The app should own only the value and delegate presentation to the system (FormatStyle).</b>`,
  crit: `<b>"Are you assembling data into a string by hand? Do the notation rules differ by culture?"</b> If both are yes, an internationalization bug is already planted — move it to a FormatStyle.`,
  ok: `① <b>Measurement + the .measurement format</b> (2.2.1) — the app owns a distance value, not the string "5km." The same data renders automatically as "5킬로미터" in Korea and "3.1 miles" in the US — exactly the value/presentation separation criterion ② <b>PersonNameComponents + .abbreviated for avatar initials</b> (2.2.2) — even the rule for extracting initials differs by culture, so delegate to the system instead of taking a substring yourself.`,
  ng: `① <b>Assembling the string <code>"\\(distance) km"</code></b> (violating 2.2.1) — the notation rule (the unit system) differs by culture, yet it is frozen into a string, violating both conditions of the criterion. An internationalization bug that forces kilometers on US users ② <b>Hardcoding "given family" order</b> (violating 2.2.2) — "\\(firstName) \\(lastName)" renders 홍길동 as "길동 홍." Name order is a cultural rule, not data, and the app has taken ownership of it.`
},
p7: {
  h3: `Direct manipulation — put actions on the object itself`,
  what: `If the object of an action is visible on screen, do not build a separate button and make people infer the relationship — <b>let them manipulate the object directly</b>.`,
  crit: `<b>"Is the object of this action visible on screen? Does the user have to infer the relationship between the button and the object?"</b> If the object is visible and inference is required, move the action onto the object.`,
  ok: `① <b>toolbarTitleMenu</b> (1.2.5) — the current folder name (the object) is visible as the title, so renaming and switching happen by tapping the title. Object and action are one, so no relationship needs explaining — and it saves a toolbar button ② <b>textSelection(.enabled) on verification codes and addresses</b> (2.1.5) — the object of the "copy" action is the text itself, so instead of a separate copy button, users long-press the text and take it directly.`,
  ng: `① <b>A separate "Change Folder" button next to the title</b> (violating 1.2.5) — the object (the folder title) is visible while the action sits in a detached button, forcing users to infer that "this button is about that title" ② <b>Screen-wide actions such as Settings or Sign Out in the title menu</b> (violating 1.2.5) — the title menu is the slot for actions on "the thing the title names." Unrelated actions make the object-action coupling itself a lie, and users stop trusting every title menu thereafter.`
}

//__ENTRIES_END__
}
};
