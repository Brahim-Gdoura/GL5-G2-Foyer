package tn.esprit.tpfoyer17;


import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.*;
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
import static org.mockito.Mockito.*;
@EnableAutoConfiguration(exclude = {
        DataSourceAutoConfiguration.class,
        HibernateJpaAutoConfiguration.class
})
class UniversiteServiceTest {


    @Mock
    private UniversiteRepository universiteRepository;

    @Mock
    private FoyerRepository foyerRepository;

    @InjectMocks
    private UniversiteService universiteService;

    private Universite universite;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
        universite = new Universite();
        universite.setIdUniversite(1L);
        universite.setNomUniversite("Esprit");
    }

    @Test
    void testAddUniversite() {
        when(universiteRepository.save(universite)).thenReturn(universite);

        Universite saved = universiteService.addUniversite(universite);

        assertNotNull(saved);
        assertEquals("Esprit", saved.getNomUniversite());
        verify(universiteRepository, times(1)).save(universite);
    }

    @Test
    void testGetAllUniversites() {
        List<Universite> universites = List.of(universite);
        when(universiteRepository.findAll()).thenReturn(universites);

        List<Universite> result = universiteService.getAllUniversites();

        assertEquals(1, result.size());
        assertEquals("Esprit", result.get(0).getNomUniversite());
        verify(universiteRepository, times(1)).findAll();
    }

    @Test
    void testGetUniversiteById() {
        when(universiteRepository.findById(1L)).thenReturn(Optional.of(universite));

        Universite found = universiteService.getUniversiteById(1L);

        assertNotNull(found);
        assertEquals(1L, found.getIdUniversite());
        verify(universiteRepository, times(1)).findById(1L);
    }

    @Test
    void testDeleteUniversite() {
        doNothing().when(universiteRepository).deleteById(1L);

        universiteService.deleteUniversite(1L);

        verify(universiteRepository, times(1)).deleteById(1L);
    }

    @Test
    void testUpdateUniversite() {
        universite.setNomUniversite("Esprit Updated");
        when(universiteRepository.save(universite)).thenReturn(universite);

        Universite updated = universiteService.updateUniversite(universite);

        assertEquals("Esprit Updated", updated.getNomUniversite());
        verify(universiteRepository, times(1)).save(universite);
    }

    @Test
    void testAffecterFoyerAUniversite() {
        Foyer foyer = new Foyer();
        foyer.setIdFoyer(10L);

        when(universiteRepository.findByNomUniversite("Esprit")).thenReturn(universite);
        when(foyerRepository.findById(10L)).thenReturn(Optional.of(foyer));
        when(universiteRepository.save(any(Universite.class))).thenReturn(universite);

        Universite result = universiteService.affecterFoyerAUniversite(10L, "Esprit");

        assertNotNull(result);
        assertEquals(foyer, result.getFoyer());
        verify(universiteRepository, times(1)).findByNomUniversite("Esprit");
        verify(foyerRepository, times(1)).findById(10L);
        verify(universiteRepository, times(1)).save(universite);
    }

    @Test
    void testDesaffecterFoyerAUniversite() {
        Foyer foyer = new Foyer();
        foyer.setIdFoyer(10L);
        universite.setFoyer(foyer);

        when(universiteRepository.findById(1L)).thenReturn(Optional.of(universite));
        when(universiteRepository.save(any(Universite.class))).thenReturn(universite);

        Universite result = universiteService.desaffecterFoyerAUniversite(1L);

        assertNull(result.getFoyer());
        verify(universiteRepository, times(1)).findById(1L);
        verify(universiteRepository, times(1)).save(universite);
    }
}
