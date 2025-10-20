package tn.esprit.tpfoyer17;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import tn.esprit.tpfoyer17.entities.Bloc;
import tn.esprit.tpfoyer17.repositories.BlocRepository;
import tn.esprit.tpfoyer17.services.BlocService;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

public class BlocServiceMockitoTest {

    @Mock
    BlocRepository blocRepository;

    @InjectMocks
    BlocService blocService;

    @BeforeEach
    public void init() {
        MockitoAnnotations.openMocks(this);
    }

    @Test
    public void testAddBloc() {
        Bloc bloc = new Bloc();
        bloc.setNomBloc("Bloc Mockito");

        when(blocRepository.save(bloc)).thenReturn(bloc);

        Bloc savedBloc = blocService.addBloc(bloc);
        assertEquals("Bloc Mockito", savedBloc.getNomBloc());
        verify(blocRepository, times(1)).save(bloc);
    }

    @Test
    public void testGetBlocById() {
        Bloc bloc = new Bloc();
        bloc.setNomBloc("Bloc Mockito Get");

        when(blocRepository.findById(1L)).thenReturn(Optional.of(bloc));

        Bloc fetchedBloc = blocService.getBlocById(1L);
        assertEquals("Bloc Mockito Get", fetchedBloc.getNomBloc());
        verify(blocRepository, times(1)).findById(1L);
    }

    @Test
    public void testUpdateBloc() {
        Bloc bloc = new Bloc();
        bloc.setNomBloc("Bloc Old");

        when(blocRepository.save(bloc)).thenReturn(bloc);

        bloc.setNomBloc("Bloc New");
        Bloc updatedBloc = blocService.updateBloc(bloc);
        assertEquals("Bloc New", updatedBloc.getNomBloc());
        verify(blocRepository, times(1)).save(bloc);
    }

    @Test
    public void testDeleteBloc() {
        doNothing().when(blocRepository).deleteById(1L);

        blocService.deleteBloc(1L);
        verify(blocRepository, times(1)).deleteById(1L);
    }
}
