package tn.esprit.tpfoyer17.services;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import tn.esprit.tpfoyer17.entities.Chambre;
import tn.esprit.tpfoyer17.entities.enumerations.TypeChambre;
import tn.esprit.tpfoyer17.repositories.ChambreRepository;

import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class ChambreServiceMockitoTest {

    @Mock
    ChambreRepository chambreRepository;

    @InjectMocks
    ChambreService chambreService;

    @Test
    public void testAddChambre() {
        Chambre input = new Chambre();
        input.setNumeroChambre(11);
        input.setTypeChambre(TypeChambre.SIMPLE);

        Chambre saved = new Chambre(1L, 11L, TypeChambre.SIMPLE, null, null);
        when(chambreRepository.save(input)).thenReturn(saved);

        Chambre result = chambreService.addChambre(input);
        assertNotNull(result);
        assertEquals(1L, result.getIdChambre());
        verify(chambreRepository, times(1)).save(input);
    }

    @Test
    public void testGetAllChambres() {
        Chambre c1 = new Chambre(1L, 10L, TypeChambre.DOUBLE, null, null);
        Chambre c2 = new Chambre(2L, 20L, TypeChambre.SIMPLE, null, null);
        List<Chambre> list = Arrays.asList(c1, c2);
        when(chambreRepository.findAll()).thenReturn(list);

        List<Chambre> result = chambreService.getAllChambres();
        assertNotNull(result);
        assertEquals(2, result.size());
        verify(chambreRepository, times(1)).findAll();
    }

    @Test
    public void testUpdateChambre() {
        Chambre existing = new Chambre(5L, 55L, TypeChambre.TRIPLE, null, null);
        Chambre updated = new Chambre(5L, 99L, TypeChambre.TRIPLE, null, null);
        when(chambreRepository.save(existing)).thenReturn(updated);

        Chambre res = chambreService.updateChambre(existing);
        assertEquals(99L, res.getNumeroChambre());
        verify(chambreRepository, times(1)).save(existing);
    }

    @Test
    public void testDeleteChambre() {
        doNothing().when(chambreRepository).deleteById(7L);
        chambreService.deleteChambre(7L);
        verify(chambreRepository, times(1)).deleteById(7L);
    }
}

