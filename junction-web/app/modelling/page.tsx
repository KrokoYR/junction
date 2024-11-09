"use client";

import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea"; // Import Textarea from shadcn
import { Loader2 } from "lucide-react";

export default function StatementModelling() {
  const [statement, setStatement] = useState("");
  const [modelledStatement, setModelledStatement] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState("");

  const handleSubmit = async () => {
    if (!statement.trim()) return;

    setIsLoading(true);
    setError("");
    setModelledStatement("");

    try {
      const response = await fetch(
        "https://junction2024.onrender.com/api/ai/statement-modelling",
        {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify({ statement }),
        },
      );

      if (!response.ok) {
        throw new Error("Failed to model statement");
      }

      const data = await response.json();
      setModelledStatement(data.statement);
    } catch (err) {
      setError("An error occurred while modelling the statement");
      console.error(err);
    } finally {
      setIsLoading(false);
    }
  };

  console.log("modelledStatement", modelledStatement);

  return (
    <div className="min-h-screen flex flex-col items-center justify-center p-4">
      <div className="w-full max-w-2xl space-y-6">
        {" "}
        {/* Increased max-width for better textarea display */}
        <div className="space-y-2">
          <Label htmlFor="statement" className="!text-xl">
            Statement to be modelled
          </Label>
          <Textarea
            id="statement"
            value={statement}
            onChange={(e) => setStatement(e.target.value)}
            placeholder="Enter your statement here..."
            disabled={isLoading}
            className="min-h-[120px] resize-y" // Made textarea taller and resizable vertically
          />
        </div>
        <Button
          onClick={handleSubmit}
          disabled={isLoading || !statement.trim()}
          className="w-full"
        >
          {isLoading ? (
            <>
              <Loader2 className="mr-2 h-4 w-4 animate-spin" />
              Processing...
            </>
          ) : (
            "Start"
          )}
        </Button>
        {statement && (
          <div className="mt-8 space-y-4">
            <div className="p-4 bg-gray-100 rounded-lg">
              <h3 className="font-semibold mb-2">Original Statement:</h3>
              <p className="whitespace-pre-wrap">{statement}</p>{" "}
              {/* Added whitespace-pre-wrap to preserve formatting */}
            </div>

            {modelledStatement && (
              <div className="p-4 bg-gray-100 rounded-lg">
                <h3 className="font-semibold mb-2">Modelled Statement:</h3>
                <p className="whitespace-pre-wrap">{modelledStatement}</p>
              </div>
            )}

            {error && (
              <div className="p-4 bg-red-100 text-red-600 rounded-lg">
                {error}
              </div>
            )}
          </div>
        )}
      </div>
    </div>
  );
}
