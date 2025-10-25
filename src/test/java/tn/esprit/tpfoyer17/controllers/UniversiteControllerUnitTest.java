package tn.esprit.tpfoyer17.controllers;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import tn.esprit.tpfoyer17.entities.Foyer;
import tn.esprit.tpfoyer17.entities.Universite;
import tn.esprit.tpfoyer17.services.IUniversiteService;

import java.util.Arrays;
import java.util.List;

import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.is;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(UniversiteController.class)
class UniversiteControllerUnitTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private IUniversiteService universiteService;

    @Autowired
    private ObjectMapper objectMapper;

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
    void testAddUniversite() throws Exception {
        // Given
        when(universiteService.addUniversite(any(Universite.class))).thenReturn(universite);

        // When & Then
        mockMvc.perform(post("/api/univeristes/add")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(universite)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.nomUniversite", is("Esprit")))
                .andExpect(jsonPath("$.adresse", is("El Ghazala")));

        verify(universiteService, times(1)).addUniversite(any(Universite.class));
    }

    @Test
    void testGetAllUniversites() throws Exception {
        // Given
        Universite universite2 = Universite.builder()
                .nomUniversite("INSAT")
                .adresse("Tunis")
                .build();
        List<Universite> universites = Arrays.asList(universite, universite2);
        when(universiteService.getAllUniversites()).thenReturn(universites);

        // When & Then
        mockMvc.perform(get("/api/univeristes/getAll"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(2)))
                .andExpect(jsonPath("$[0].nomUniversite", is("Esprit")))
                .andExpect(jsonPath("$[1].nomUniversite", is("INSAT")));

        verify(universiteService, times(1)).getAllUniversites();
    }

    @Test
    void testGetUniversiteById() throws Exception {
        // Given
        long universiteId = 1L;
        when(universiteService.getUniversiteById(universiteId)).thenReturn(universite);

        // When & Then
        mockMvc.perform(get("/api/univeristes/get")
                        .param("idUniversite", String.valueOf(universiteId)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.nomUniversite", is("Esprit")))
                .andExpect(jsonPath("$.adresse", is("El Ghazala")));

        verify(universiteService, times(1)).getUniversiteById(universiteId);
    }

    @Test
    void testDeleteUniversite() throws Exception {
        // Given
        long universiteId = 1L;
        doNothing().when(universiteService).deleteUniversite(universiteId);

        // When & Then
        mockMvc.perform(delete("/api/univeristes/delete/{idUniversite}", universiteId))
                .andExpect(status().isOk());

        verify(universiteService, times(1)).deleteUniversite(universiteId);
    }

    @Test
    void testUpdateUniversite() throws Exception {
        // Given
        Universite updatedUniversite = Universite.builder()
                .nomUniversite("Esprit Updated")
                .adresse("El Ghazala Updated")
                .build();
        when(universiteService.updateUniversite(any(Universite.class))).thenReturn(updatedUniversite);

        // When & Then
        mockMvc.perform(put("/api/univeristes/update")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(updatedUniversite)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.nomUniversite", is("Esprit Updated")))
                .andExpect(jsonPath("$.adresse", is("El Ghazala Updated")));

        verify(universiteService, times(1)).updateUniversite(any(Universite.class));
    }

    @Test
    void testAffecterFoyerAUniversite() throws Exception {
        // Given
        long foyerId = 1L;
        String nomUniversite = "Esprit";
        universite.setFoyer(foyer);
        
        when(universiteService.affecterFoyerAUniversite(foyerId, nomUniversite))
                .thenReturn(universite);

        // When & Then
        mockMvc.perform(put("/api/univeristes/affecter-foyer-universite")
                        .param("idFoyer", String.valueOf(foyerId))
                        .param("nomUniversite", nomUniversite))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.nomUniversite", is("Esprit")));

        verify(universiteService, times(1)).affecterFoyerAUniversite(foyerId, nomUniversite);
    }

    @Test
    void testDesaffecterFoyerAUniversite() throws Exception {
        // Given
        long universiteId = 1L;
        universite.setFoyer(null);
        
        when(universiteService.desaffecterFoyerAUniversite(universiteId))
                .thenReturn(universite);

        // When & Then
        mockMvc.perform(put("/api/univeristes/desaffecter-foyer-universite")
                        .param("idUniversite", String.valueOf(universiteId)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.nomUniversite", is("Esprit")));

        verify(universiteService, times(1)).desaffecterFoyerAUniversite(universiteId);
    }
}
