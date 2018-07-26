/* 
 * Copyright (c) 2018 José Tomás Atria <jtatria at gmail.com>.
 * All rights reserved. This work is licensed under a Creative Commons
 * Attribution-NonCommercial-NoDerivatives 4.0 International License.
 */

package edu.columbia.incite.obo.debug;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.uima.analysis_engine.AnalysisEngineProcessException;
import org.apache.uima.cas.FSIterator;
import org.apache.uima.cas.text.AnnotationIndex;
import org.apache.uima.jcas.JCas;
import org.apache.uima.util.Level;

import edu.columbia.incite.uima.AbstractProcessor;
import edu.columbia.incite.uima.api.types.obo.Section;
import edu.columbia.incite.uima.api.types.obo.Session;

/**
 *
 * @author José Tomás Atria <jtatria@gmail.com>
 */
public class DateFix extends AbstractProcessor {

    private final Pattern p = Pattern.compile( "([0-9]{8})" );

    @Override
    protected void realProcess( JCas jcas ) throws AnalysisEngineProcessException {   
        Session sssn = null;
        String sssnYear = null;
        String sssnDate = null;
        AnnotationIndex<Session> sessions = jcas.getAnnotationIndex( Session.class );
        if( sessions.size() != 1 ) {
            if( sessions.size() < 1 ) {
                getLogger().log( Level.WARNING, "No session annotation for CAs {0}", getDocumentId() );
            } else if( sessions.size() > 1 ) {
                getLogger().log( Level.WARNING, "Multiple session annotations for CAs {0}", getDocumentId() );
            }
        } else {
            sssn = sessions.iterator().next();
            sssnYear = sssn.getYear();
            sssnDate = sssn.getDate();
        }
        
        AnnotationIndex<Section> sections = jcas.getAnnotationIndex( Section.class );
        FSIterator<Section> it = sections.iterator();
        
        while( it.hasNext() ) {
            Section sec = it.next();
            String id   = sec.getId();
            String year = sec.getYear();
            String date = sec.getDate();
            
            if( date != null && year != null ) continue;

            if( date == null ) {
                getLogger().log( Level.FINE, "No date for {0}", id );
                String nuDate = null;
                if( sssnDate != null ) {
                    getLogger().log( Level.FINE, "Using date from session data for {0}", id );
                    nuDate = sssnDate;
                }
                else {
                    Matcher m = p.matcher( id );
                    if( m.matches() ) {
                        getLogger().log( Level.FINE, "Using date from section id for {0}", id );
                        nuDate = m.group( 1 );
                    }
                }
                if( nuDate != null ) {
                    sec.setDate( nuDate );
                } else {
                    getLogger().log( Level.INFO, "No data for missing date for {0}", id );
                }
                date = sec.getDate();
            }
            
            if( year == null ) {
                getLogger().log( Level.FINE, "No year for {0}", id );
                String nuYear = null;
                if( sssnYear != null ) {
                    getLogger().log( Level.FINE, "Using year from session data for {0}", id );
                    nuYear = sssnYear;
                }
                else if( date != null ) {
                    getLogger().log( Level.FINE, "Extracting year from date for {0}", id );
                    nuYear = date.substring( 0, 4 );
                }
                if( nuYear != null ) {
                    sec.setYear( nuYear );
                } else {
                    getLogger().log( Level.INFO, "No data for missing year for {0}", id );
                }
            }
            int i = 0;
        }
    }       
}
