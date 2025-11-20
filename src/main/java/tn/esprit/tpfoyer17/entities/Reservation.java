package tn.esprit.tpfoyer17.entities;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.FieldDefaults;

import java.io.Serializable;
import java.util.Date;
import java.util.Set;

@Entity
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
@ToString
@FieldDefaults(level = AccessLevel.PRIVATE)
public class Reservation implements Serializable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    Long idReservation;

    Date anneeUniversitaire;

    boolean estValide;

    @ToString.Exclude
    @ManyToMany(mappedBy = "reservations")
    Set<Etudiant> etudiants;

    @JsonIgnore
    @ToString.Exclude
    @ManyToOne
    Chambre chambre;
}
