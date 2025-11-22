package tn.esprit.tpfoyer17;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration;
import org.springframework.boot.autoconfigure.orm.jpa.HibernateJpaAutoConfiguration;
import tn.esprit.tpfoyer17.entities.Foyer;
import tn.esprit.tpfoyer17.entities.Universite;
import tn.esprit.tpfoyer17.repositories.FoyerRepository;
import tn.esprit.tpfoyer17.repositories.UniversiteRepository;
import tn.esprit.tpfoyer17.services.UniversiteService;

import java.util.*;

import static org.junit.jupiter.api.Assertions.*;

@EnableAutoConfiguration(exclude = {
        DataSourceAutoConfiguration.class,
        HibernateJpaAutoConfiguration.class
})
class UniversiteWithoutMock {

    private UniversiteService universiteService;

    private Universite universite;
    private Foyer foyer;


    @Test
    void testAddUniversiteWithNull() {
        assertThrows(IllegalArgumentException.class, () -> universiteService.addUniversite(null));
    }

    @Test
    void testAddUniversiteWithEmptyName() {
        Universite emptyNameUniversite = new Universite();
        emptyNameUniversite.setNomUniversite("");

        Universite saved = universiteService.addUniversite(emptyNameUniversite);

        assertNotNull(saved);
        assertEquals("", saved.getNomUniversite());
    }


    @Test
    void testGetUniversiteByIdNotFound() {
        Universite found = universiteService.getUniversiteById(999L);

        assertNull(found);
    }


    @Test
    void testDeleteUniversiteNotFound() {
        assertDoesNotThrow(() -> universiteService.deleteUniversite(999L));
    }


    @Test
    void testUpdateUniversiteWithNull() {
        assertThrows(IllegalArgumentException.class, () -> universiteService.updateUniversite(null));
    }

    @Test
    void testAffecterFoyerAUniversiteWithNonExistingFoyer() {
        Universite result = universiteService.affecterFoyerAUniversite(999L, "Esprit");

        assertNull(result);
    }

    @Test
    void testAffecterFoyerAUniversiteWithNonExistingUniversite() {
        Universite result = universiteService.affecterFoyerAUniversite(10L, "Non Existing University");

        assertNull(result);
    }


    @Test
    void testAffecterFoyerAUniversiteWithNullUniversiteName() {
        Universite result = universiteService.affecterFoyerAUniversite(10L, null);

        assertNull(result);
    }

    @Test
    void testDesaffecterFoyerAUniversiteNotFound() {
        Universite result = universiteService.desaffecterFoyerAUniversite(999L);

        assertNull(result);
    }





    @Test
    void testMultipleUniversitesOperations() {
        // Test adding multiple universities
        Universite universite2 = new Universite();
        universite2.setIdUniversite(2L);
        universite2.setNomUniversite("University 2");

        Universite universite3 = new Universite();
        universite3.setIdUniversite(3L);
        universite3.setNomUniversite("University 3");

        universiteService.addUniversite(universite2);
        universiteService.addUniversite(universite3);

        List<Universite> allUniversites = universiteService.getAllUniversites();

        assertEquals(3, allUniversites.size());
        assertTrue(allUniversites.stream().anyMatch(u -> u.getNomUniversite().equals("University 2")));
        assertTrue(allUniversites.stream().anyMatch(u -> u.getNomUniversite().equals("University 3")));
    }

    @Test
    void testUniversiteWithSpecialCharacters() {
        Universite specialUniversite = new Universite();
        specialUniversite.setIdUniversite(4L);
        specialUniversite.setNomUniversite("Université avec accents é è à");

        Universite saved = universiteService.addUniversite(specialUniversite);

        assertNotNull(saved);
        assertEquals("Université avec accents é è à", saved.getNomUniversite());
    }

    @Test
    void testAffecterFoyerThenDesaffecter() {
        // First affect foyer
        Universite result1 = universiteService.affecterFoyerAUniversite(10L, "Esprit");
        assertNotNull(result1);
        assertNotNull(result1.getFoyer());
        assertEquals(10L, result1.getFoyer().getIdFoyer());

        // Then desaffect foyer
        Universite result2 = universiteService.desaffecterFoyerAUniversite(1L);
        assertNotNull(result2);
        assertNull(result2.getFoyer());
    }



}