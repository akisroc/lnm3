package auth

import (
	"auth/internal/db"
	"log"
	"net"
	"os"

	"github.com/joho/godotenv"
	"google.golang.org/grpc"
)

func main() {
	godotenv.Load()

	// Init DB
	_ = db.Connect(os.Getenv("DATABASE_URL"))

	// Init gRPC server
	lis, err := net.Listen("tcp", ":50051")
	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}

	s := grpc.NewServer()

	log.Println("Auth gRPC service started on port 50051")
	if err := s.Serve(lis); err != nil {
		log.Fatalf("failed to serve: %v", err)
	}
}

//import(
//	"context"
//	"database/sql"
//)
//
//func (s *Server) Register(ctx context.Context, req *pb.RegisterRequest) (*pb.RegisterResponse, error) {
//	return &pb.RegisterResponse{
//		UserId: "uuid-222222",
//		Message: "User created successfully"
//	}, nil
//}

// func (s *server) Login(ctx context.Context, req *pb.LoginRequest) (*pb.LoginResponse, error) {
// 	if req.GetEmail() != "" {
// 		// Check if email exists
// 		user, err := s.db.GetUserByEmail(ctx, req.GetEmail())
// 		if err != nil {
// 			return nil, status.Errorf(codes.NotFound, "email not found")
// 		}
// 	} else {
// 		user, err := s.db.GetUserByUsername(ctx, req.Get)
// 	}
// }
