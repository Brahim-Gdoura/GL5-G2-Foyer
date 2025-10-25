package tn.esprit.tpfoyer17;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import tn.esprit.tpfoyer17.entities.Foyer;
import tn.esprit.tpfoyer17.repositories.FoyerRepository;
import tn.esprit.tpfoyer17.repositories.UniversiteRepository;
import tn.esprit.tpfoyer17.services.FoyerService;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

public class FoyerServiceMockitoTest {

    @Mock
    FoyerRepository foyerRepository;

    @Mock
    UniversiteRepository universiteRepository;

    @InjectMocks
    FoyerService foyerService;

    @BeforeEach
    public void init() {
        MockitoAnnotations.openMocks(this);
    }

    // ✅ Test: Add Foyer
    @Test
    public void testAddFoyer() {
        Foyer foyer = new Foyer();
        foyer.setNomFoyer("Foyer Mockito");
        foyer.setCapaciteFoyer(200L);

        when(foyerRepository.save(foyer)).thenReturn(foyer);

        Foyer savedFoyer = foyerService.addFoyer(foyer);

        assertEquals("Foyer Mockito", savedFoyer.getNomFoyer());
        assertEquals(200L, savedFoyer.getCapaciteFoyer());
        verify(foyerRepository, times(1)).save(foyer);
    }

    // ✅ Test: Get Foyer By ID
    @Test
    public void testGetFoyerById() {
        Foyer foyer = new Foyer();
        foyer.setNomFoyer("Foyer Universitaire");

        when(foyerRepository.findById(1L)).thenReturn(Optional.of(foyer));

        Foyer foundFoyer = foyerService.getFoyerById(1L);

        assertNotNull(foundFoyer);
        assertEquals("Foyer Universitaire", foundFoyer.getNomFoyer());
        verify(foyerRepository, times(1)).findById(1L);
    }

    // ✅ Test: Update Foyer
    @Test
    public void testUpdateFoyer() {
        Foyer foyer = new Foyer();
        foyer.setNomFoyer("Ancien Foyer");
        foyer.setCapaciteFoyer(100L);

        when(foyerRepository.save(foyer)).thenReturn(foyer);

        foyer.setNomFoyer("Nouveau Foyer");
        foyer.setCapaciteFoyer(150L);
        Foyer updatedFoyer = foyerService.updateFoyer(foyer);

        assertEquals("Nouveau Foyer", updatedFoyer.getNomFoyer());
        assertEquals(150L, updatedFoyer.getCapaciteFoyer());
        verify(foyerRepository, times(1)).save(foyer);
    }

    // ✅ Test: Delete Foyer
    @Test
    public void testDeleteFoyer() {
        doNothing().when(foyerRepository).deleteById(1L);

        foyerService.deleteFoyer(1L);

        verify(foyerRepository, times(1)).deleteById(1L);
    }
}
