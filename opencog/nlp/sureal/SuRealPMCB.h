/*
 * SuRealPMCB.h
 *
 * Copyright (C) 2014 OpenCog Foundation
 *
 * Author: William Ma <https://github.com/williampma>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License v3 as
 * published by the Free Software Foundation and including the exceptions
 * at http://opencog.org/wiki/Licenses
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program; if not, write to:
 * Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */

#ifndef _OPENCOG_SUREAL_PMCB_H
#define _OPENCOG_SUREAL_PMCB_H


#include <opencog/query/DefaultPatternMatchCB.h>
#include <opencog/guile/SchemeEval.h>


namespace opencog
{
namespace nlp
{

/**
 * A PatternMatchCallback for Surface Realization.
 *
 * Override the neccessary callbacks to do special handling of variables
 * and LG dictionary checks.
 */
class SuRealPMCB : public DefaultPatternMatchCB
{
public:
    SuRealPMCB(AtomSpace* as, const std::set<Handle>& vars);
    ~SuRealPMCB();

    virtual bool variable_match(const Handle& hPat, const Handle& hSoln);
    virtual bool clause_match(const Handle& pattrn_link_h, const Handle& grnd_link_h);
    virtual bool grounding(const std::map<Handle, Handle> &var_soln,
                           const std::map<Handle, Handle> &pred_soln);
    virtual void initiate_search(PatternMatchEngine* pPME,
                                const std::set<Handle>& vars,
                                const HandleSeq& clauses);

    std::map<Handle, std::vector<std::map<Handle, Handle> > > m_results;   // store the PM results

private:
    virtual Handle find_starter(Handle, size_t&, Handle&, size_t&);

    std::set<Handle> m_vars;   // store nodes that are variables

    SchemeEval* m_eval;
};

}
}

#endif // _OPENCOG_SUREAL_PMCB_H
