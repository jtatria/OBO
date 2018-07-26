/* 
 * Copyright (c) 2018 José Tomás Atria <jtatria at gmail.com>.
 * All rights reserved. This work is licensed under a Creative Commons
 * Attribution-NonCommercial-NoDerivatives 4.0 International License.
 */

package edu.columbia.incite.obo.uima.io;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.uima.cas.CASException;
import org.apache.uima.cas.Feature;
import org.apache.uima.cas.FeatureStructure;
import org.apache.uima.cas.text.AnnotationFS;
import org.apache.uima.fit.descriptor.ConfigurationParameter;
import org.apache.uima.jcas.cas.FSArray;
import org.apache.uima.jcas.tcas.Annotation;
import org.apache.uima.util.Level;
import org.xml.sax.SAXException;

import edu.columbia.incite.uima.api.types.Span;
import edu.columbia.incite.uima.api.types.Tuple;
import edu.columbia.incite.uima.api.types.obo.Charge;
import edu.columbia.incite.uima.api.types.obo.OBOSegment;
import edu.columbia.incite.uima.api.types.obo.OBOSpan;
import edu.columbia.incite.uima.api.types.obo.Offence;
import edu.columbia.incite.uima.api.types.obo.Person;
import edu.columbia.incite.uima.api.types.obo.Section;
import edu.columbia.incite.uima.api.types.obo.Session;
import edu.columbia.incite.uima.api.types.obo.TrialAccount;
import edu.columbia.incite.uima.api.types.obo.Verdict;
import edu.columbia.incite.uima.io.InciteSaxHandler;
import edu.columbia.incite.uima.util.JCasTools;

/**
 * SAX handler extension to deal with data directives in the TEI encoding of the Old Bailey Online.
 *
 * @author José Tomás Atria <jtatria@gmail.com>
 */
public class OBOSaxHandler extends InciteSaxHandler {

    public static final String PARAM_APPLY_DIRECTIVES = "interps";
    @ConfigurationParameter(
         name = PARAM_APPLY_DIRECTIVES, mandatory = false, defaultValue = "true",
        description = "Apply data directives from 'interp' XML elements."
    )
    private Boolean interp;

    public static final String PARAM_CREATE_COMPOSITES = "joins";
    @ConfigurationParameter(
         name = PARAM_CREATE_COMPOSITES, mandatory = false, defaultValue = "true",
        description = "Build Composite entities from 'join' XML elements."
    )
    private Boolean joins;

    public static final String PARAM_ADD_PROC_DATA = "addProc";
    @ConfigurationParameter(
        name = PARAM_ADD_PROC_DATA, mandatory = false, defaultValue = "true",
        description = "Retain processing data for downstream use."
    )
    private boolean addProc;

    private ProcessingStatus proc;

    // Null on reset
    private Session session;
    private Section curSection;

    @Override
    public void startDocument() throws SAXException {
        super.startDocument();
        this.proc = new ProcessingStatus();
    }

    @Override
    public void endDocument() throws SAXException {
        clearDirectives();
        clearReferences();
        addProcData();
        proc.reset();
        super.endDocument();
    }
    
    @Override
    public void reset() {
        super.reset();
        this.session = null;
        this.curSection = null;
    }


    @Override
    protected Annotation createSpanAnnotation( 
        int start, String qName, String path, Map<String,String> data 
    ) {
        OBOSpan ann = (OBOSpan) super.createSpanAnnotation( start, qName, path, data );
        ann.setXpath( path );
        proc.register( ann );
        if( ann instanceof Section ) {
            Section sec = (Section) ann;
            curSection = curSection == null ? sec : resolveSectionConflict( curSection, sec );
        }
        return ann;
    }


    @Override
    protected void finishAnnotation( Annotation ann ) {
        super.finishAnnotation( ann );
        if( ann instanceof Section ) curSection = null;
    }

    @Override
    protected void processOtherData( 
        int start, String qName, String path, Map<String, String> data 
    ) {
        if( !( interp || joins ) ) return;
        proc.pendingDirectives.add( new DataDirective( start, qName, path, data ) );
    }

    private void clearDirectives() {
        if( proc.pendingDirectives == null ) return;
        List<DataDirective> failures = new ArrayList<>();
        proc.pendingDirectives.removeIf( ( DataDirective dir ) -> {
            try {
                if( dir.tag.equals( "interp" ) ) return processInterp( dir );
                if( dir.tag.equals( "join" ) ) return processJoin( dir );
            } catch( CASException ex ) {
                getLogger().log( Level.WARNING, ex.toString() );
            }
            return true;
        } );
        failures.addAll( proc.pendingDirectives );
    }

    private void clearReferences() {
        if( proc.pendingReferences == null ) return;
        for( Span ann : proc.pendingReferences.keySet() ) {
            List<Tuple> tuples = proc.pendingReferences.get( ann );
            FeatureStructure[] array = tuples.toArray( new FeatureStructure[tuples.size()] );
            FSArray tuplesFS = new FSArray( getJCas(), tuples.size() );
            tuplesFS.copyFromArray( tuples.toArray( array ), 0, 0, tuples.size() );
            ann.setTuples( tuplesFS );
            getJCas().addFsToIndexes( tuplesFS );
        }
        proc.pendingReferences.clear();
    }

    private boolean processInterp( DataDirective dir ) {
        String dataType = dir.getInterpType();
        if( dataType.equals( "collection" ) || dataType.equals( "uri" ) ) return true;

        // Locate target annotation
        Span target = proc.resolve( dir.getInterpTarget() );
        if( target == null ) {
            getLogger().log( Level.FINE, "Unknown target {0} for interp at {1}",
                new Object[] { dir.getInterpTarget(), dir.path }
            );
            return false; // No target, bail with failure.
        }

        // Get feature for data field
        String featName = null;
        if( dataType.toLowerCase().matches( ".*subcategory" ) ) featName = "subcategory";
        else if( dataType.toLowerCase().matches( ".*category" ) ) featName = "category";
        else if( dataType.toLowerCase().matches( "type" ) ) featName = "placeType";
        else featName = dataType;
        Feature feat = target.getType().getFeatureByBaseName( featName );
        if( feat == null ) {
            getLogger().log(
                Level.WARNING, "Missing feature {0} for data type {1} in type {2} at {3}"
                , new Object[] {
                    featName, dir.getInterpType(), target.getType().getShortName(), dir.path
                }
            );
            return false; // No target feature, bail with failure
        }

        // Log overwrites
        if( target.getFeatureValueAsString( feat ) != null
            && !target.getFeatureValueAsString( feat ).equals( dir.getInterpValue() ) ) {
            getLogger().log( Level.WARNING
                , "Overwriting feature {0} with value {1} for entity {2} with new value {3}"
                , new Object[]{
                    feat.getShortName(),
                    target.getFeatureValueAsString( feat ),
                    target.getId(),
                    dir.getInterpValue()
                }
            );
        }

        target.setFeatureValueFromString( feat, dir.getInterpValue() );
        return true;
    }

    private boolean processJoin( DataDirective dir ) throws CASException {
        boolean out = true;
        // Resolve target annotations
        List<Span> targets = new ArrayList<>();
        for( String targetId : dir.getJoinTargets() ) {
            Span target = proc.resolve( targetId );
            if( target == null ) {
                getLogger().log( Level.WARNING, "Unknown target {0} for join at {1}"
                    , new Object[]{ targetId, dir.path }
                );
                out = false;
            }
            targets.add( target );
        }

        if( dir.getJoinType().equals( "criminalCharge" ) ) {
            // Create new criminalCharge
            Charge charge = new Charge( getJCas() );
            charge.setChargeId( dir.getJoinId() );
            charge.setDefendant( (Person) targets.get( 0 ) );
            charge.setOffence( (Offence) targets.get( 1 ) );
            if( targets.size() >= 3 ) charge.setVerdict( (Verdict) targets.get( 2 ) );
            getJCas().addFsToIndexes( charge );

            OBOSegment context = dir.context;
            if( context instanceof TrialAccount ) {
                TrialAccount trial = (TrialAccount) dir.context;
                FSArray newCharges;
                if( trial.getCharges() != null ) {
                    FSArray oldCharges = trial.getCharges();
                    newCharges = new FSArray( getJCas(), oldCharges.size() + 1 );
                    newCharges.copyFromArray( oldCharges.toArray(), 0, 0, oldCharges.size() );
                } else {
                    newCharges = new FSArray( getJCas(), 1 );
                }
                newCharges.set( newCharges.size() - 1, charge );
                trial.setCharges( newCharges );
            } else {
                getLogger().log( Level.WARNING, 
                    "Context {0} at {1} for criminal charge {2} is not a trial account"
                    , new Object[]{
                        dir.context.getId(), dir.context.getXpath(), charge.getChargeId()
                    }

                );
            }
        } else {
            Tuple tuple = new Tuple( getJCas() );
            tuple.setSubject( targets.get( 0 ) );
            tuple.setObject( targets.get( 1 ) );
            tuple.setPredicate( dir.getJoinType() );
            getJCas().addFsToIndexes( tuple );
            for( Span target : targets ) {
                proc.pendingReferences.computeIfAbsent( target,
                    t -> new ArrayList<>()
                ).add( tuple );
            }
        }

        return out;
    }

    private void addProcData() {
        if( !addProc ) return;
        String[] dupes = proc.getDupes();
        String[] does = proc.getDoes();
        String[] dirs = proc.getPendingDirs();
        if( does != null || dupes != null || dirs != null ) {
            Session sssn = (Session) getJCas().getAnnotationIndex( Session.type ).iterator().next();
            getJCas().removeFsFromIndexes( sssn );
            if( dirs  != null )
                sssn.setProc_dirs( JCasTools.makeArray( getJCas(), proc.getPendingDirs() ) );
            if( does  != null )
                sssn.setProc_does( JCasTools.makeArray( getJCas(), proc.getDoes() ) );
            if( dupes != null )
                sssn.setProc_dupes( JCasTools.makeArray( getJCas(), proc.getDupes() ) );
            getJCas().addFsToIndexes( sssn );
        }
    }

    private Section resolveSectionConflict( Section old, Section neu ) {
        getLogger().log( Level.WARNING, "Section overlap: {0} {1} at {2} contains {3} {4} at {5} ",
            new Object[]{
                old.getOboType(), old.getId(), old.getXpath(),
                neu.getOboType(), neu.getId(), neu.getXpath()
            }
        );

        if( neu.getOboType().equals( "trialAccount" ) ) return neu;
        if( old.getOboType().equals( "trialAccount" ) ) return old;
        else return old;
    }

    private class ProcessingStatus {
        Map<String,List<AnnotationFS>> entityDirectory = annotate ? new HashMap<>() : null;
        List<DataDirective> pendingDirectives = ( interp || joins )? new ArrayList<>() : null;
        Map<Span,ArrayList<Tuple>> pendingReferences = joins ? new HashMap<>() : null;

        private boolean register( OBOSpan a  ) {
            boolean ret = true;

            String id = a.getId();

            // TODO: refactor this using a more intelligent data structure and not relying on null 
            // as valid markers.
            
            // id has been seen before...
            if( entityDirectory.containsKey( id ) ) {
                // ...and it points to a valid entity: duplicate id.
                if( entityDirectory.get( id ).get( 0 ) != null ) {
                    entityDirectory.get( id ).add( a );
                    ret = false;
                } else { // ...but it does not point to a valid entity: it was a doe.
                    entityDirectory.get( id ).set( 0, a );
                }
            } else { // id has not been seen.
                entityDirectory.put( id, new ArrayList<>() );
                entityDirectory.get( id ).add(a );
            }
            return ret;
        }

        private Span resolve( String id ) {
            // Unknwon id. it is a doe, add null entry.
            if( !proc.entityDirectory.containsKey( id ) ) {
                ArrayList<AnnotationFS> nullEntry = new ArrayList<>();
                nullEntry.add( null );
                proc.entityDirectory.put( id, nullEntry );
            }

            return (Span) proc.entityDirectory.get( id ).get( 0 );
        }

        private void reset() {
            this.entityDirectory = null;
            this.pendingDirectives = null;
            this.pendingReferences = null;
        }

        private String[] getDupes() {
            List<String> dupes = new ArrayList<>();
            for( Map.Entry<String,List<AnnotationFS>> e : entityDirectory.entrySet() ) {
                if( e.getValue().size() > 1 ) {
                    dupes.add( e.getKey() );
                }
            }
            return dupes.size() > 0 ? dupes.toArray( new String[dupes.size()] ) : null;
        }

        private String[] getDoes() {
            List<String> does = new ArrayList<>();
            for( Map.Entry<String,List<AnnotationFS>> e : entityDirectory.entrySet() ) {
                if( e.getValue().size() == 1 && e.getValue().get( 0 ) == null ) {
                    does.add( e.getKey() );
                }
            }
            return does.size() > 0 ? does.toArray( new String[does.size()] ) : null;
        }

        private String[] getPendingDirs() {
            List<String> dirs = new ArrayList<>();
            for( DataDirective dir : pendingDirectives ) {
                dirs.add( dir.serialize() );
            }
            return dirs.size() > 0 ? dirs.toArray( new String[dirs.size()] ) : null;
        }
    }

    private class DataDirective {

        public static final String KEY_INTERP_TYPE = "type";
        public static final String KEY_INTERP_INST = "inst";
        public static final String KEY_INTERP_VALUE = "value";

        public static final String KEY_JOIN_TARGETS = "targets";
        public static final String KEY_JOIN_RESULT = "result";
        public static final String KEY_JOIN_ID = "id";

        final int pos;
        final String tag;
        final String path;
        final Map<String,String> data;
        final OBOSegment context;

        private DataDirective( int pos, String tag, String path, Map<String,String> data ) {
            OBOSaxHandler daddy = OBOSaxHandler.this;
            this.pos = pos;
            this.tag = tag;
            this.path = path;
            this.data = data;
            this.context = daddy.curSection == null ? daddy.session : daddy.curSection;
        }

        private String serialize() {
            StringBuilder builder = new StringBuilder();
            data.entrySet().stream().forEach( ( e ) -> {
                builder.append( builder.length() == 0 ? "{ " : "," );
                builder.append( String.format( "\"%s\":\"%s\"", e.getKey(), e.getValue() ) );
            } );
            builder.append( " }" );
            return String.format(
                "{ \"tag\":\"%s\", \"pos\":%d, \"path\":\"%s\", \"data\":%s }",
                tag, pos, path, builder.toString()
            );
        }

        String getInterpType() {
            return data.get( KEY_INTERP_TYPE );
        }

        String getInterpTarget() {
            return data.get( KEY_INTERP_INST );
        }

        String getInterpValue() {
            return data.get( KEY_INTERP_VALUE );
        }

        String[] getJoinTargets() {
            return data.get( KEY_JOIN_TARGETS ).split( "\\s+" );
        }

        String getJoinType() {
            return data.get( KEY_JOIN_RESULT );
        }

        String getJoinId() {
            return data.get( KEY_JOIN_ID );
        }
    }

}
