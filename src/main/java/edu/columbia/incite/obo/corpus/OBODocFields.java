/* 
 * Copyright (c) 2018 José Tomás Atria <jtatria at gmail.com>.
 * All rights reserved. This work is licensed under a Creative Commons
 * Attribution-NonCommercial-NoDerivatives 4.0 International License.
 */

package edu.columbia.incite.obo.corpus;

import java.util.HashSet;
import java.util.Set;

import org.apache.lucene.document.Document;
import org.apache.uima.cas.CASException;
import org.apache.uima.cas.text.AnnotationFS;
import org.apache.uima.fit.descriptor.ConfigurationParameter;
import org.apache.uima.jcas.cas.FSArray;
import org.apache.uima.util.Level;

import edu.columbia.incite.uima.api.types.Paragraph;
import edu.columbia.incite.uima.api.types.obo.Section;
import edu.columbia.incite.uima.api.types.obo.Session;
import edu.columbia.incite.uima.api.types.obo.Charge;
import edu.columbia.incite.uima.api.types.obo.Offence;
import edu.columbia.incite.uima.api.types.obo.TrialAccount;
import edu.columbia.incite.uima.api.types.obo.Verdict;
import edu.columbia.incite.uima.index.InciteLuceneBroker;

/**
 *
 * @author José Tomás Atria <jtatria@gmail.com>
 */
public class OBODocFields extends InciteLuceneBroker {
    
    public static final String OBO_PREFIX         = "obo";
    public static final String OBO_SESSION_FIELD  = OBO_PREFIX + SEP + "session";
    public static final String OBO_DATE_FIELD     = OBO_PREFIX + SEP + "date";
    public static final String OBO_YEAR_FIELD     = OBO_PREFIX + SEP + "year";
    public static final String OBO_SECTION_FIELD  = OBO_PREFIX + SEP + "section";
    public static final String OBO_TYPE_FIELD     = OBO_PREFIX + SEP + "type";
    public static final String OBO_XPATH_FIELD    = OBO_PREFIX + SEP + "xpath";
    public static final String OBO_OFF_CAT        = OBO_PREFIX + SEP + "offCat";
    public static final String OBO_OFF_SUBCAT     = OBO_PREFIX + SEP + "offSubcat";
    public static final String OBO_VER_CAT        = OBO_PREFIX + SEP + "verCat";
    public static final String OBO_VER_SUBCAT     = OBO_PREFIX + SEP + "verSubcat";
    public static final String OBO_PARAID         = OBO_PREFIX + SEP + "paraId";
    
    public static final String PARAM_ADD_LEGAL = "addLegal";
    @ConfigurationParameter( name = PARAM_ADD_LEGAL, mandatory = false, defaultValue = "true" )
    private Boolean addLegal;
    
    @Override
    public void values( AnnotationFS ann, Document tgt ) throws CASException {
        // Date, Label
        // Named, Person, Place
        // Legal, Offence, Verdict, Punishment
        
        if( ann instanceof Session ) {                
            Session sssn = (Session) ann;
            
            String id = sssn.getId();
            if( id != null ) {
                addData( OBO_SESSION_FIELD, id, Types.STRING, tgt );
            } else {
                getLogger().log( Level.FINE, "Missing date for session {0}", sssn.getId() );
            }
            /*
            TODO: debug why the addition of long-valued fields introduces universal indexed but not 
            stored terms with values: [ 50,02,00,00 ] and [ 40,08,00,00,00,00 ] for date and year 
            and [ 30,20,00,00,00,00,00,00 ] for year.
            
            Until then, all fields are strings
            
            */
            String date = sssn.getDate();
            if( date != null ) {
                addData( OBO_DATE_FIELD, date, Types.STRING, tgt );
//                addData( OBO_DATE_FIELD, Long.decode( date ), Types.INTEGER, tgt );
            } else {
                getLogger().log( Level.FINE, "Missing date for session {0}", sssn.getId() );
            }

            String year = sssn.getYear();
            if( year != null ) {
                addData( OBO_YEAR_FIELD, year, Types.STRING, tgt );
//                addData( OBO_YEAR_FIELD, Long.decode( year ), Types.INTEGER, tgt );
            } else if( date != null ) {
                year = date.substring( 0, 4 );
                addData( OBO_YEAR_FIELD, year, Types.STRING, tgt );
//                addData( OBO_YEAR_FIELD, Long.decode( year ), Types.INTEGER, tgt );
            }                
        }
        
        if( ann instanceof Section ) {
            Section sctn = (Section) ann;
            
            String id = sctn.getId();
            if( id != null ) {
                addData( OBO_SECTION_FIELD, id,    Types.STRING, tgt );
            }
            else {
                getLogger().log( Level.FINE, "Missing id for OBO section!" );
            }
            
            String type = sctn.getOboType();
            if( type != null ) {
                addData( OBO_TYPE_FIELD,    type,  Types.STRING, tgt );
            }
            else {
                getLogger().log( Level.FINE, "Missing type for OBO section!" );
            }
            
            String xpath = sctn.getXpath();
            if( xpath != null ) {
                addData( OBO_XPATH_FIELD,   xpath, Types.STRING, tgt );
            }
            else {
                getLogger().log( Level.FINE, "Missing xpath for OBO section!" );
            }
        }
        
        if( ann instanceof TrialAccount && addLegal ) {
            TrialAccount ta = (TrialAccount) ann;
            FSArray charges = ta.getCharges();
            if( charges != null ) {
                Set<String> offCats    = new HashSet<>();
                Set<String> verCats    = new HashSet<>();
                Set<String> offSubcats = new HashSet<>();
                Set<String> verSubcats = new HashSet<>();
                
                for( int i = 0; i < charges.size(); i++ ) {
                    Charge c = (Charge) charges.get( i );
                    
                    Offence o = c.getOffence();
                    if( o != null ) {
                        String offCat    = o.getCategory();
                        if( offCat != null ) offCats.add( offCat );
                        String offSubcat = o.getSubcategory();
                        if( offSubcat != null ) offSubcats.add( offSubcat );
                    } else {
                        getLogger().log( Level.FINE, 
                            "null offence for charge {0} in trial {1}"
                            , new Object[]{ c.getChargeId(), ta.getId() }
                        );
                    }
                    
                    Verdict v = c.getVerdict();
                    if( v != null ) {
                        String verCat = v.getCategory();
                        if( verCat != null ) verCats.add( verCat );
                        String verSubcat = v.getSubcategory();
                        if( verSubcat != null ) verSubcats.add( verSubcat );
                    } else {
                        getLogger().log( Level.FINE, 
                            "null verdict for charge {0} in trial {1}"
                            , new Object[]{ c.getChargeId(), ta.getId() }
                        );
                    }
                    
                }
                
                offCats.stream().filter( ( s ) -> !( "".equals( s ) ) ).forEach( ( s ) -> {
                    addData( OBO_OFF_CAT, s, Types.STRING, tgt );
                } );
                
                verCats.stream().filter( ( s ) -> !( "".equals( s ) ) ).forEach( ( s ) -> {
                    addData( OBO_VER_CAT, s, Types.STRING, tgt );
                } );
                
                offSubcats.stream().filter( ( s ) -> !( "".equals( s ) ) ).forEach( ( s ) -> {
                    addData( OBO_OFF_SUBCAT, s, Types.STRING, tgt );
                } );
                
                verSubcats.stream().filter( ( s ) -> !( "".equals( s ) ) ).forEach( ( s ) -> {
                    addData( OBO_VER_SUBCAT, s, Types.STRING, tgt );
                } );
                
            } else {
                getLogger().log( Level.FINE, 
                    "null charges for trial {0}", new Object[]{ ta.getId() } 
                );
            }
        }
        
        if( ann instanceof Paragraph ) {            
            Paragraph para = (Paragraph) ann;
            addData( OBO_PARAID, para.getId(), Types.STRING, tgt );
        }
    }
    
}
