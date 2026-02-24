## User Journeys

### Journey 1: Henry (CEO) - Shaping Company Ethos with AI Collaboration

**Opening Scene - The Branding Bottleneck:**

Henry sits in his home office, preparing for a Series A pitch meeting next week. He needs to articulate Seven Fortunas's mission, values, and brand voice—but the company is moving so fast that documentation lags behind reality. He's written fragments in Google Docs, Slack messages, and scattered notes, but nothing is cohesive.

In the past, he would have hired a branding consultant ($15K-30K, 4-6 weeks) or spent weeks writing everything himself. Both options feel wrong: consultants don't understand the AI-native vision, and Henry's time is better spent on strategy and fundraising.

**Rising Action - Discovering the Second Brain:**

Day 3 after MVP launch, Jorge mentions the `7f-brand-system-generator` skill deployed in the Second Brain. Henry is skeptical—can AI really capture his vision?

He opens the command palette and types `/7f-brand-system-generator`. The skill prompts him through a conversational session:
- "Describe your mission in one sentence..."
- "What does digital inclusion mean to Seven Fortunas?"
- "How should we sound when talking to marginalized communities vs. investors?"

Henry speaks his responses using the voice input system (OpenAI Whisper), and the AI transcribes perfectly. The conversation feels natural—like talking to a thoughtful brand strategist who asks clarifying questions.

**Climax - The Aha Moment:**

30 minutes later, Henry reviews the generated brand documentation:
- Mission statement (crisp, compelling)
- Core values (authentically Seven Fortunas)
- Voice & tone guidelines (appropriate for each audience)
- Example messaging for investor pitch, community outreach, technical blog

It's 80% there—not perfect, but better than his scattered notes. He edits 20% to add personal touches, and the AI learns from his changes. Henry runs the skill again for the website homepage copy—this time, it nails the voice on the first try.

**Resolution - New Reality:**

**Aha moment:** "AI permeates everywhere. I can shape our organization's ethos easily in collaboration with AI."

Henry no longer feels like branding and content creation are bottlenecks. In 2 hours, he's generated:
- Brand documentation for the Second Brain
- Investor pitch narrative
- Website homepage copy
- Social media messaging

The infrastructure didn't just "host" his content—it actively helped him create it. When the new marketing hire joins next month, they'll have a solid foundation to build on instead of starting from scratch.

**Journey Requirements Revealed:**
- Voice input system (speech-to-text)
- Custom skill creation (`7f-brand-system-generator`)
- Second Brain content structure (brand system)
- AI collaboration workflows (iterative generation + human refinement)

---

### Journey 2: Patrick (CTO) - Infrastructure Validation at AI Speed

**Opening Scene - The Technical Debt Worry:**

Patrick has been CTO at three startups. Each time, the founding team moved fast and created technical debt that haunted them for years: inconsistent repo naming, missing documentation, no security scanning, tangled dependencies.

When Henry proposes building Seven Fortunas's infrastructure in 5 days using an autonomous agent, Patrick's alarm bells ring. "Moving fast" usually means "creating mess."

**Rising Action - Reviewing the Architecture:**

Day 2, Jorge shares the architecture document and invites Patrick to review the technical design. Patrick reads:
- ADRs (Architectural Decision Records) for key choices
- Security-first approach (Dependabot, secret scanning, branch protection)
- BMAD library integration (70+ production-tested workflows)
- Testing built into autonomous development cycle

Patrick tests the infrastructure on Day 3:
```bash
gh api /orgs/Seven-Fortunas/repos  # Clean, consistent naming
cat seven-fortunas-brain/CLAUDE.md  # Comprehensive agent instructions
gh secret scanning alerts  # Active, catching test secrets
```

**Climax - The Aha Moment:**

Patrick runs a code review using `/bmad-bmm-code-review` skill on a generated GitHub Actions workflow. The AI agent:
- Identifies a potential race condition
- Suggests idempotent retry logic
- References architecture document and ADR-006 (Workflow Reliability)
- Proposes specific code fix

Patrick is stunned. The infrastructure isn't just "fast"—it's **thoughtfully designed**. Security is enforced by default. Documentation exists. Best practices are encoded in skills.

**Aha moment:** "Using AI to accomplish tasks is effortless. SW development infrastructure is well done."

**Resolution - New Reality:**

Patrick stops worrying about technical debt. The infrastructure has built-in quality gates:
- Security scanning catches issues automatically
- BMAD skills encode best practices
- Architecture is documented with ADRs
- AI agents enforce consistency

When Patrick hires the first engineering team, they'll inherit a solid foundation—not a mess to clean up. He can focus on product architecture instead of fixing infrastructure problems.

**Journey Requirements Revealed:**
- Architecture documentation (ADRs, technical specs)
- Code review workflows (automated + AI-assisted)
- Security automation (Dependabot, secret scanning, branch protection)
- BMAD skill library (encoded best practices)
- GitHub CLI automation (testing infrastructure quality)

---

### Journey 3: Buck (VP Engineering) - Security on Autopilot

**Opening Scene - The Security Paranoia:**

Buck has been hacked before. At his previous startup, an engineer accidentally committed an AWS key to GitHub. Within 4 hours, attackers spun up $50K in compute resources mining cryptocurrency. The company almost died.

Now at Seven Fortunas, Buck is hypervigilant. Every commit, every PR, every config change—he manually reviews for security issues. He knows this doesn't scale, but he can't shake the paranoia.

**Rising Action - Testing the Security Controls:**

Jorge invites Buck to test the security infrastructure. Buck is skeptical—automated security tools have high false-positive rates and miss real issues.

Buck deliberately tries to commit secrets to test the system:
```bash
echo "ANTHROPIC_API_KEY=sk-ant-fake-key-12345" > .env
git add .env
git commit -m "test: check secret detection"
```

**BLOCKED.** The pre-commit hook (detect-secrets) catches it:
```
ERROR: Potential secrets detected in .env
  Line 1: ANTHROPIC_API_KEY=sk-ant-fake-key-12345

Commit aborted. Remove secrets before committing.
```

Buck tries bypassing with `--no-verify`. **BLOCKED.** GitHub Actions runs the same check server-side and fails the build.

Buck tries a subtle leak (Base64-encoded key in a comment). **CAUGHT.** Secret scanning flags it within minutes.

**Climax - The Aha Moment:**

Buck opens the GitHub Security dashboard:
- ✅ Dependabot enabled (13 dependency alerts triaged)
- ✅ Secret scanning active (caught Buck's test secrets)
- ✅ Code scanning (CodeQL) analyzing every PR
- ✅ Branch protection (no force-push to main)
- ✅ 2FA required for all team members

Buck realizes: **the system caught everything he threw at it**. Not as an afterthought—security was designed in from the start.

**Aha moment:** "It's flagging any attempts to push sensitive data. Code review and test infrastructure already configured."

**Resolution - New Reality:**

Buck stops manually reviewing every commit for security issues. He trusts the automated controls:
- Pre-commit hooks catch secrets before they're committed
- GitHub scans every push for leaked credentials
- Dependabot updates vulnerable dependencies automatically
- Code scanning finds SQL injection, XSS, and other OWASP Top 10 issues

Buck shifts focus from **preventing** security issues to **responding** to alerts. When Dependabot flags a critical vulnerability, Buck investigates and patches—but he's not wasting time on false alarms or missed commits.

Security is **on autopilot**, not on Buck's shoulders.

**Journey Requirements Revealed:**
- Pre-commit hooks (detect-secrets)
- GitHub security features (secret scanning, Dependabot, CodeQL)
- Branch protection rules
- 2FA enforcement
- Security dashboard (visibility into posture)
- Automated testing (security built into development cycle)

---

### Journey 4: Jorge (VP AI-SecOps) - Autonomous Agent Success

**Opening Scene - The Enabler Bottleneck:**

Jorge is the most experienced with AI, infrastructure, and security. The team relies on him for everything: setting up repos, configuring workflows, deploying BMAD skills, architecting systems.

Jorge knows this doesn't scale. When Seven Fortunas grows to 10, 20, 50 people, he can't be the bottleneck. But building infrastructure manually takes months—and they need it in days.

Jorge reads about Claude Code SDK and autonomous agents. The promise: 60-70% of infrastructure built autonomously, Jorge refines the remaining 30-40%. But he's skeptical—AI agents get stuck, hallucinate, create broken code.

**Rising Action - Launching the Autonomous Agent:**

Day 1, Jorge launches the autonomous agent:
```bash
cd /home/ladmin/seven-fortunas-workspace/7f-infrastructure-project
./scripts/run_autonomous_continuous.sh
```

The initializer agent reads the PRD, generates `feature_list.json` with 28 features, and hands off to the coding agent. Jorge monitors progress:

- **Hour 2:** GitHub orgs created, teams structured ✅
- **Hour 4:** BMAD library deployed, 18 skills symlinked ✅
- **Hour 6:** Second Brain scaffolded (directories, placeholder content) ✅
- **Hour 8:** AI Advancements Dashboard implemented (RSS feeds, GitHub releases) ✅

**3 features marked "blocked"** (X API integration, needs authorization). Agent logs issue and moves on—no infinite loops, no hallucinations.

**Climax - The Aha Moment:**

End of Day 1: Jorge reviews the generated infrastructure:
- 18 features completed (64%)
- 3 features blocked (requires human authorization)
- 7 features pending (autonomous agent continues tomorrow)
- **Zero broken features** (all tests passed before marking complete)

Jorge expected to debug hallucinations, fix broken code, untangle messes. Instead, he's reviewing working infrastructure. The agent followed bounded retry logic (max 3 attempts per feature), tested before committing, logged clear error messages for blocked features.

**Aha moment:** "The implementation is working with minimal or no issues."

**Resolution - New Reality:**

Jorge shifts from "do everything" to "enable everything":
- Days 1-2: Autonomous agent builds 60-70% of infrastructure
- Days 3-5: Jorge refines, unblocks features, applies real branding

When Henry needs a new skill (`7f-brand-system-generator`), Jorge creates it once using the meta-skill. Henry uses it repeatedly without Jorge's help.

Jorge is no longer the bottleneck—he's the enabler. The infrastructure scales with the team, not with Jorge's bandwidth.

**Journey Requirements Revealed:**
- Autonomous agent infrastructure (Claude Code SDK)
- Bounded retry logic (max 3 attempts per feature)
- Testing built into development cycle
- Feature tracking (`feature_list.json`)
- Clear error logging (blocked features documented)
- Meta-skill for skill creation (self-service enablement)
- BMAD library deployment (reusable workflows)

---

### Additional User Types

**5. Operations/Admin User (Future Team Member)**
- **Need:** Manage GitHub organization, configure workflows, monitor dashboards
- **Journey:** Admin needs to add new team member, grant repo access, configure branch protection—uses GitHub CLI automation and BMAD management skills instead of manual UI clicking

**6. Support/Troubleshooting User (Future)**
- **Need:** Debug failed workflows, investigate dashboard data issues, resolve access problems
- **Journey:** Support engineer investigates "AI Dashboard not updating"—follows documented troubleshooting procedures, checks GitHub Actions logs, validates API credentials

**7. External Contributor (Open Source)**
- **Need:** Contribute to public repos, understand project structure, follow contribution guidelines
- **Journey:** Open-source developer finds Seven Fortunas public repo, reads comprehensive README, clones repo, runs tests locally, submits PR following CONTRIBUTING.md guidelines

---

### Journey Requirements Summary

**Capabilities Revealed by Journeys:**

1. **Voice Input System** (Henry) - OpenAI Whisper cross-platform
2. **Custom Skill Creation** (Henry, Jorge) - Meta-skill for generating domain-specific skills
3. **Second Brain Content Structure** (Henry, Patrick) - Progressive disclosure, AI-accessible
4. **AI Collaboration Workflows** (Henry) - Iterative generation + human refinement
5. **Architecture Documentation** (Patrick) - ADRs, technical specs, design decisions
6. **Code Review Automation** (Patrick) - BMAD skills + AI-assisted review
7. **Security Automation** (Buck) - Pre-commit hooks, secret scanning, Dependabot, CodeQL
8. **GitHub CLI Automation** (Patrick, Buck, Jorge) - Programmatic org/repo management
9. **Autonomous Agent Infrastructure** (Jorge) - Claude Code SDK, bounded retries, testing
10. **Feature Tracking System** (Jorge) - Progress monitoring, blocked feature management
11. **BMAD Library Deployment** (All) - 70+ reusable workflows, self-service skills
12. **Dashboard Auto-Update** (Future) - GitHub Actions cron jobs, API integrations

---

