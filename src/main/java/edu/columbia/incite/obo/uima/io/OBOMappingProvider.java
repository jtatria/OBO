/* 
 * Copyright (C) 2017 José Tomás Atria <jtatria at gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
package edu.columbia.incite.obo.uima.io;

import java.util.Arrays;
import java.util.Map;

import org.apache.uima.analysis_engine.AnalysisEngineProcessException;
import org.apache.uima.cas.CAS;
import org.apache.uima.cas.Feature;
import org.apache.uima.cas.Type;
import org.apache.uima.cas.TypeSystem;
import org.apache.uima.fit.component.Resource_ImplBase;
import org.apache.uima.resource.ResourceConfigurationException;
import org.apache.uima.util.Level;

import edu.columbia.incite.uima.tools.MappingProvider;
import edu.columbia.incite.uima.api.types.obo.*;
import edu.columbia.incite.uima.util.Types;

/**
 * Mapping provider for TEI mark up in the Old Bailey Online.
 *
 * @author José Tomás Atria <jtatria@gmail.com>
 */
public class OBOMappingProvider extends Resource_ImplBase implements MappingProvider {

    private static final String[] DATA_TAGS = { "interp", "join" };
    private static final String[] ANN_TAGS  = { "div0", "div1", "persName", "placeName", "rs" };
    // Two comments. First, lb has to be ignored because the source material is sprinkled with 
    // <lb/> tags inside perfectly reasonable word streams, which breaks downstream tokenizers 
    // (i.e. priso<lb/>ner, encoded to preserve the original publication's formatting, breaks the 
    // word 'prisoner' into two meaningless tokens 'priso' and 'ner'.
    //
    // Second, this is the best we can do for now until InciteSaxHandler offers a more reasonable
    // approach for handling line breaks, as in the strictest of senses, the 'isLineBreak()' method
    // should be removed from this interface.
    // UPDATE: upstream now provides "isInlineMark" for dealing with all layout marks.
    // TODO: check isInlineMark and remove above.
    private static final String[] LM_TAGS   = { "lb", "xptr" };
//    private static final String[] LM_TAGS   = { "xptr" };
    private static final String[] PB_TAGS   = { "p" };

    private Type sessionType;
    private Type sectionType;
    private Type trialType;

    private Type entityType;
    private Type personType;
    private Type placeType;
    private Type dateType;
    private Type labelType;

    private Type offType;
    private Type verType;
    private Type punType;

    private TypeSystem ts;

    @Override
    public void configure( CAS cas ) throws ResourceConfigurationException {
        if( this.ts != null && this.ts.equals( cas.getTypeSystem() ) ) return;
        this.ts = cas.getTypeSystem();
        try {         
            sessionType = Types.checkType( ts,      Session.class.getName() );
            sectionType = Types.checkType( ts,      Section.class.getName() );
            trialType   = Types.checkType( ts, TrialAccount.class.getName() );
            
            entityType  = Types.checkType( ts,    OBOEntity.class.getName() );
            personType  = Types.checkType( ts,       Person.class.getName() );
            placeType   = Types.checkType( ts,        Place.class.getName() );
            dateType    = Types.checkType( ts,         Date.class.getName() );
            labelType   = Types.checkType( ts,        Label.class.getName() );
            
            offType     = Types.checkType( ts,      Offence.class.getName() );
            verType     = Types.checkType( ts,      Verdict.class.getName() );
            punType     = Types.checkType( ts,   Punishment.class.getName() );
        } catch ( AnalysisEngineProcessException ex ) {
            throw new ResourceConfigurationException( ex );
        }
    }

    @Override
    public Type getType( String key, Map<String,String> data ) {
        String type = data != null && data.containsKey( "type" ) ? data.get( "type" ) : "";
        switch( key ) {
            case "div0" : return sessionType;
            case "div1" : return type.equals( "trialAccount" ) ? trialType : sectionType;
            case "persName" : return personType;
            case "placeName" : return placeType;
            case "rs" : switch( type ) {
                case "offenceDescription" : return offType;
                case "verdictDescription" : return verType;
                case "punishmentDescription" : return punType;
                case "crimeDate" : return dateType;
                case "occupation" : case "alias": return labelType;
                default :
                    getLogger().log( Level.WARNING, "Can't disambiguate entity type" );
                    return entityType;
            }
            default :
                getLogger().log( Level.WARNING, "Type requested for unknown key " + key );
                return null;
        }
    }

    @Override
    public Feature getFeature( Type type, String key ) {
        String featName = key;
        if( key.equals( "type" ) ) featName = "oboType";
        return type.getFeatureByBaseName( featName );
    }

    @Override
    public boolean isData( String key ) {
        return check( key, DATA_TAGS, ANN_TAGS );
    }

    @Override
    public boolean isAnnotation( String key ) {
        return check( key, ANN_TAGS );
    }

    @Override
    public boolean isInlineMark( String key ) {
        return check( key, LM_TAGS );
    }

    @Override
    public boolean isParaBreak( String key ) {
        return check( key, PB_TAGS );
    }

    private boolean check( String key, String[]... arrays ) {
        for( String[] array : arrays ) {
            if( Arrays.asList( array ).contains( key ) ) return true;
        }
        return false;
    }
}
