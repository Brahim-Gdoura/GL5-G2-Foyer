package tn.esprit.tpfoyer17.services;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import tn.esprit.tpfoyer17.entities.Foyer;
import tn.esprit.tpfoyer17.entities.Universite;
import tn.esprit.tpfoyer17.repositories.FoyerRepository;
import tn.esprit.tpfoyer17.repositories.UniversiteRepository;

import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class UniversiteServiceUnitTest {

    @Mock
    private UniversiteRepository universiteRepository;

    @Mock
    private FoyerRepository foyerRepository;

    @InjectMocks
    private UniversiteService universiteService;

    private Universite universite;
    private Foyer foyer;

    @BeforeEach
    void setUp() {
        universite = Universite.builder()
                .nomUniversite("Esprit")
                .adresse("El Ghazala")
                .build();

        foyer = Foyer.builder()
                .nomFoyer("Foyer Central")
                .capaciteFoyer(500)
                .build();
    }

    @Test
    void testAddUniversite() {
        // Given
        when(universiteRepository.save(any(Universite.class))).thenReturn(universite);

        // When
        Universite savedUniversite = universiteService.addUniversite(universite);

        // Then
        assertNotNull(savedUniversite);
        assertEquals("Esprit", savedUniversite.getNomUniversite());
        assertEquals("El Ghazala", savedUniversite.getAdresse());
        verify(universiteRepository, times(1)).save(universite);
    }

    @Test
    void testGetAllUniversites() {
        // Given
        Universite universite2 = Universite.builder()
                .nomUniversite("INSAT")
                .adresse("Tunis")
                .build();
        List<Universite> universites = Arrays.asList(universite, universite2);
        when(universiteRepository.findAll()).thenReturn(universites);

        // When
        List<Universite> result = universiteService.getAllUniversites();

        // Then
        assertNotNull(result);
        assertEquals(2, result.size());
        assertEquals("Esprit", result.get(0).getNomUniversite());
        assertEquals("INSAT", result.get(1).getNomUniversite());
        verify(universiteRepository, times(1)).findAll();
    }

    @Test
    void testGetUniversiteById() {
        // Given
        long universiteId = 1L;
        when(universiteRepository.findById(universiteId)).thenReturn(Optional.of(universite));

        // When
        Universite result = universiteService.getUniversiteById(universiteId);

        // Then
        assertNotNull(result);
        assertEquals("Esprit", result.getNomUniversite());
        verify(universiteRepository, times(1)).findById(universiteId);
    }

    @Test
    void testDeleteUniversite() {
        // Given
        long universiteId = 1L;
        doNothing().when(universiteRepository).deleteById(universiteId);

        // When
        universiteService.deleteUniversite(universiteId);

        // Then
        verify(universiteRepository, times(1)).deleteById(universiteId);
    }

    @Test
    void testUpdateUniversite() {
        // Given
        Universite updatedUniversite = Universite.builder()
                .nomUniversite("Esprit Updated")
                .adresse("El Ghazala Updated")
                .build();
        when(universiteRepository.save(any(Universite.class))).thenReturn(updatedUniversite);

        // When
        Universite result = universiteService.updateUniversite(updatedUniversite);

        // Then
        assertNotNull(result);
        assertEquals("Esprit Updated", result.getNomUniversite());
        assertEquals("El Ghazala Updated", result.getAdresse());
        verify(universiteRepository, times(1)).save(updatedUniversite);
    }

    @Test
    void testAffecterFoyerAUniversite() {
        // Given
        long foyerId = 1L;
        String nomUniversite = "Esprit";
        
        when(universiteRepository.findByNomUniversite(nomUniversite)).thenReturn(universite);
        when(foyerRepository.findById(foyerId)).thenReturn(Optional.of(foyer));
        when(universiteRepository.save(any(Universite.class))).thenReturn(universite);

        // When
        Universite result = universiteService.affecterFoyerAUniversite(foyerId, nomUniversite);

        // Then
        assertNotNull(result);
        assertNotNull(result.getFoyer());
        assertEquals("Foyer Central", result.getFoyer().getNomFoyer());
        verify(universiteRepository, times(1)).findByNomUniversite(nomUniversite);
        verify(foyerRepository, times(1)).findById(foyerId);
        verify(universiteRepository, times(1)).save(universite);
    }

    @Test
    void testDesaffecterFoyerAUniversite() {
        // Given
        long universiteId = 1L;
        universite.setFoyer(foyer);
        
        when(universiteRepository.findById(universiteId)).thenReturn(Optional.of(universite));
        when(universiteRepository.save(any(Universite.class))).thenAnswer(invocation -> {
            Universite univ = invocation.getArgument(0);
            return univ;
        });

        // When
        Universite result = universiteService.desaffecterFoyerAUniversite(universiteId);

        // Then
        assertNotNull(result);
        assertNull(result.getFoyer());
        verify(universiteRepository, times(1)).findById(universiteId);
        verify(universiteRepository, times(1)).save(any(Universite.class));
    }

    @Test
    void testAffecterFoyerAUniversiteWithNullFoyer() {
        // Given
        long foyerId = 999L;
        String nomUniversite = "Esprit";
        
        when(universiteRepository.findByNomUniversite(nomUniversite)).thenReturn(universite);
        when(foyerRepository.findById(foyerId)).thenReturn(Optional.empty());

        // When & Then
        assertThrows(Exception.class, () -> {
            universiteService.affecterFoyerAUniversite(foyerId, nomUniversite);
        });
    }

    @Test
    void testGetUniversiteByIdNotFound() {
        // Given
        long universiteId = 999L;
        when(universiteRepository.findById(universiteId)).thenReturn(Optional.empty());

        // When & Then
        assertThrows(Exception.class, () -> {
            universiteService.getUniversiteById(universiteId);
        });
    }
}
