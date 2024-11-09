"use client";

import { useState, useEffect } from "react";
import { Button } from "@/components/ui/button";
import { QRCodeSVG } from "qrcode.react";
import axios from "axios";
import { useRouter } from "next/navigation";
import { useToast } from "@/hooks/use-toast";

interface SessionData {
  session_key: string;
  expires_at: string;
}

const LOCAL_STORAGE_KEY = "sessionData";
axios.defaults.withCredentials = true;

export default function Home() {
  const router = useRouter();
  const { toast } = useToast();

  const [loading, setLoading] = useState(false);
  const [sessionData, setSessionData] = useState<SessionData | null>(() => {
    // Initialize from localStorage on component mount
    if (typeof window !== "undefined") {
      const stored = localStorage.getItem(LOCAL_STORAGE_KEY);
      if (stored) {
        const parsed = JSON.parse(stored);
        // Check if session is expired
        if (new Date(parsed.expires_at) > new Date()) {
          return parsed;
        }
      }
    }
    return null;
  });
  const [isVerified, setIsVerified] = useState(false);

  useEffect(() => {
    let interval: NodeJS.Timeout;

    if (sessionData?.session_key && !isVerified) {
      interval = setInterval(async () => {
        try {
          const encodedSessionKey = encodeURIComponent(sessionData.session_key);
          const response = await axios.get(
            `https://junction2024.onrender.com/api/session/is_verified?session_key=${encodedSessionKey}`,
            {
              withCredentials: true,
            },
          );
          if (response.data.is_verified) {
            setIsVerified(true);
            clearInterval(interval);

            toast({
              title: "Successfully verified!",
              description: "Redirecting to modelling page...",
              variant: "success",
            });
            // Redirect to /modelling
            setTimeout(() => {
              router.push("/modelling");
            }, 2500);
          }
        } catch (error) {
          console.error("Error checking verification:", error);
        }
      }, 5000);
    }

    return () => {
      if (interval) {
        clearInterval(interval);
      }
    };
  }, [sessionData, isVerified]);

  const createSession = async () => {
    setLoading(true);
    try {
      const response = await axios.post(
        "https://junction2024.onrender.com/api/session/create",
        {},
        {
          withCredentials: true,
        },
      );
      const newSessionData = response.data;
      // Save to localStorage
      localStorage.setItem(LOCAL_STORAGE_KEY, JSON.stringify(newSessionData));
      setSessionData({
        session_key: newSessionData.session_key,
        expires_at: newSessionData.expires_at,
      });
      // Start polling after setting session data
    } catch (error) {
      console.error("Error creating session:", error);
    } finally {
      setLoading(false);
    }
  };

  // Check if session is expired
  const isSessionExpired = sessionData
    ? new Date(sessionData.expires_at) <= new Date()
    : true;

  return (
    <main className="flex min-h-screen flex-col items-center justify-center p-24">
      {(!sessionData || isSessionExpired) && !loading && (
        <Button onClick={createSession}>Login</Button>
      )}

      {loading && (
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-gray-900"></div>
      )}

      {sessionData && !isSessionExpired && !isVerified && (
        <div className="flex flex-col items-center gap-4">
          <QRCodeSVG value={JSON.stringify(sessionData)} size={256} />
          <p className="text-sm text-gray-500">
            Expires at: {new Date(sessionData.expires_at).toLocaleString()}
          </p>
        </div>
      )}

      {isVerified && !isSessionExpired && (
        <div className="text-green-500">
          <svg
            xmlns="http://www.w3.org/2000/svg"
            className="h-24 w-24"
            fill="none"
            viewBox="0 0 24 24"
            stroke="currentColor"
          >
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth={2}
              d="M5 13l4 4L19 7"
            />
          </svg>
        </div>
      )}
    </main>
  );
}
