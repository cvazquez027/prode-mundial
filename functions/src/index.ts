import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();

const db = admin.firestore();

// Se dispara cuando se actualiza un partido
export const onMatchResultUpdated = functions.firestore
  .document("matches/{matchId}")
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    // Solo procesar si el partido pasó a "finished" y tiene resultado
    if (
      before.status === after.status ||
      after.status !== "finished" ||
      after.homeScore === null ||
      after.awayScore === null
    ) {
      return null;
    }

    const matchId = context.params.matchId;
    const realHome = after.homeScore;
    const realAway = after.awayScore;

    // Obtener todas las predicciones para este partido
    const predictionsSnap = await db
      .collection("predictions")
      .where("matchId", "==", matchId)
      .get();

    if (predictionsSnap.empty) return null;

    const batch = db.batch();

    for (const predDoc of predictionsSnap.docs) {
      const pred = predDoc.data();
      const predictedHome = pred.homeScore;
      const predictedAway = pred.awayScore;

      // Calcular puntos (lógica 1+1+1)
      let points = 0;

      const predictedWinner = Math.sign(predictedHome - predictedAway);
      const realWinner = Math.sign(realHome - realAway);

      if (predictedWinner === realWinner) {
        points += 1;

        if ((predictedHome - predictedAway) === (realHome - realAway)) {
          points += 1;

          if (predictedHome === realHome && predictedAway === realAway) {
            points += 1;
          }
        }
      }

      // Actualizar puntos en la predicción
      batch.update(predDoc.ref, {pointsEarned: points});

      // Actualizar puntos totales del usuario
      const userRef = db.collection("users").doc(pred.userId);
      batch.update(userRef, {
        totalPoints: admin.firestore.FieldValue.increment(points),
        correctResults: admin.firestore.FieldValue.increment(
          predictedWinner === realWinner ? 1 : 0
        ),
        exactScores: admin.firestore.FieldValue.increment(
          predictedHome === realHome && predictedAway === realAway ? 1 : 0
        ),
      });
    }

    await batch.commit();
    console.log(`✅ Puntos calculados para partido ${matchId}`);
    return null;
  });